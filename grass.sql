/*
 * Types
 */
CREATE TYPE Operation AS ENUM (
    'Abs'
    ,'App'
    ,'Out'
    ,'Succ'
    ,'Char'
    ,'In'
);

CREATE TYPE App AS (
    func Int
    ,arg Int
);

CREATE TYPE Node AS (
    l Int
    ,r Int
    ,op Operation
    ,app App -- for 'App'
    ,ascii Int -- for 'Char'
);

CREATE TYPE Tree AS (
    nodes Node[]
);

CREATE TYPE Code AS (
    trees Tree[]
);

CREATE TYPE Env AS (
    idx int[]
);

CREATE TYPE DumpElem AS (
    code Code
    ,env Env
);

CREATE TYPE Dump AS (
    elems DumpElem[]
);

CREATE TYPE ClosureElem AS (
    code Code
    ,env Env
);

CREATE TYPE Closure AS (
    elems ClosureElem[]
);

CREATE TYPE Machine AS (
    code Code
    ,env Env
    ,dump Dump
    ,closure Closure
);


/*
 * Data constructor
 */
CREATE OR REPLACE FUNCTION node (l Int, r Int, Operation, App, ascii Int) RETURNS Node AS $$
    SELECT ($1,$2,$3,$4,$5)::Node
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION abs_node (l Int, r Int) RETURNS Node AS $$
    SELECT node($1,$2,'Abs',NULL,NULL)
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION app_node (l Int, r Int, App) RETURNS Node AS $$
    SELECT node($1,$2,'App',$3,NULL)
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION in_node () RETURNS Node AS $$
    SELECT node(1,2,'In',NULL,NULL)
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION char_node (ascii Int) RETURNS Node AS $$
    SELECT node(1,2,'Char',NULL,$1)
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION succ_node () RETURNS Node AS $$
    SELECT node(1,2,'Succ',NULL,NULL)
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION out_node () RETURNS Node AS $$
    SELECT node(1,2,'Out',NULL,NULL)
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION tree (Node[]) RETURNS Tree AS $$
    SELECT ROW($1)::Tree
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION code (Tree[]) RETURNS Code AS $$
    SELECT ROW($1)::Code
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION env (Int[]) RETURNS Env AS $$
    SELECT ROW($1)::Env
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION dump_elem (Code, Env) RETURNS DumpElem AS $$
    SELECT ($1, $2)::DumpElem
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION dump (DumpElem[]) RETURNS Dump AS $$
    SELECT ROW($1)::Dump
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION closure_elem (Code, Env) RETURNS ClosureElem AS $$
    SELECT ($1, $2)::ClosureElem
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION closure (ClosureElem[]) RETURNS Closure AS $$
    SELECT ROW($1)::Closure
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION char_closure_elem (ascii Int) RETURNS ClosureElem AS $$
    SELECT 
        closure_elem(
            code( ARRAY[ tree( ARRAY[char_node($1)] ) ] )
            ,env( ARRAY[ ]::Int[] )
        )
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION machine (Code, Env, Dump, Closure) RETURNS Machine AS $$
    SELECT ($1, $2, $3, $4)::Machine
$$ LANGUAGE SQL
;

/*
 * Tree Manipulation Function
 */
-- Return a root node of tree
CREATE OR REPLACE FUNCTION root (Tree) RETURNS Node AS $$
    SELECT
        node(l,r,op,app,ascii)
    FROM
        unnest($1.nodes) AS t(l,r,op,app,ascii)
    WHERE
        l = 1
$$ LANGUAGE SQL
;

-- retrun an array of node at second depth of tree
CREATE OR REPLACE FUNCTION subroots (Tree) RETURNS Node[] AS $$
    WITH RECURSIVE rec(nextl, node) AS (
        SELECT
            r + 1 AS nextl
            ,node(l,r,op,app,ascii) AS node
        FROM
            unnest($1.nodes) AS t(l,r,op,app,ascii)
        WHERE
            l = 2
        UNION ALL
        SELECT
            t.r + 1 AS nextl
            ,node(l,r,op,app,ascii) AS node
        FROM
            unnest($1.nodes) AS t(l,r,op,app,ascii)
            ,rec
        WHERE
            rec.nextl <> (root($1)).r 
            AND l = rec.nextl
    )
    SELECT
        array_agg(node)
    FROM
        rec
$$ LANGUAGE SQL IMMUTABLE STRICT
;

-- fix a left number of tree to 0
CREATE OR REPLACE FUNCTION fix_tree_offset (Tree) RETURNS Tree AS $$
    SELECT
        tree(array_agg(node))
    FROM(
        SELECT
            node(l-tree_offset, r-tree_offset, op, app,ascii) as node
        FROM
            unnest($1.nodes) AS node(l,r,op,app,ascii)
        CROSS JOIN(
            SELECT
                min(l) - 1 AS tree_offset
            FROM
                unnest($1.nodes) AS t(l,r,op,app,ascii)
        )t
    )t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

-- return subtree
CREATE OR REPLACE FUNCTION subtree (Tree, Node) RETURNS Tree AS $$
    SELECT
        fix_tree_offset( tree(array_agg(node)) )
    FROM(
        SELECT
            node(l,r,op,app,ascii) AS node
        FROM
            unnest($1.nodes) AS t(l,r,op,app,ascii)
        WHERE
            l BETWEEN ($2).l AND ($2).r
    )t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

-- return
CREATE OR REPLACE FUNCTION subtrees (Tree) RETURNS Tree[] AS $$
    WITH RECURSIVE
    rec(idx, tree) AS (
        SELECT
            1::Int
            ,subtree($1, (subroots($1))[1])
        UNION ALL
        SELECT
            idx
            ,subtree($1, current_root)
        FROM(
            SELECT
                idx+1 AS idx
                ,(subroots($1))[idx+1] AS current_root
            FROM
                rec
            LIMIT 1
        ) t
        WHERE
            idx <= array_length(subroots($1), 1)
    )
    SELECT
        array_agg(tree)
    FROM
        rec
$$ LANGUAGE SQL IMMUTABLE STRICT
;

/*
 * Utility
 */
CREATE OR REPLACE FUNCTION isEmpty (Code) RETURNS Bool AS $$
    SELECT ($1).trees = ARRAY[]::Tree[]
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION isEmpty (Dump) RETURNS Bool AS $$
    SELECT ($1).elems = ARRAY[]::DumpElem[]
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION tail(anyarray) RETURNS anyarray AS $$
    SELECT $1[2:array_length($1,1)]
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION consume(Code) RETURNS Code AS $$
    SELECT code(tail($1.trees))
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION consume(Dump) RETURNS Dump AS $$
    SELECT dump(tail($1.elems))
$$ LANGUAGE SQL
;

-- get ascii code
CREATE OR REPLACE FUNCTION get_ascii (Machine) RETURNS Int AS $$
    SELECT
        (node).ascii
    FROM(
        SELECT
            root((closure).code.trees[1]) AS node
        FROM(
            SELECT ($1).closure.elems[($1).env.idx[1]] AS closure
        ) t
    ) t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

-- get character
CREATE OR REPLACE FUNCTION get_char (Machine) RETURNS Text AS $$
    SELECT chr(get_ascii($1))
$$ LANGUAGE SQL IMMUTABLE STRICT
;

/*
 * 実行
 */
-- function definition : abs
CREATE OR REPLACE FUNCTION exec_abs (Tree[], Machine) RETURNS Machine AS $$
    SELECT
        machine(
            consume(($2).code)
            ,env(
                    array_length(($2).closure.elems, 1) + 1
                    || ($2).env.idx
            )
            ,($2).dump
            ,closure(
                array_append(
                    ($2).closure.elems
                    ,closure_elem(code($1), ($2).env)
                )
            )
        )
$$ LANGUAGE SQL IMMUTABLE STRICT
;

-- function application : app
CREATE OR REPLACE FUNCTION exec_app (Node, Machine) RETURNS Machine AS $$
    WITH func(idx) AS (
        SELECT ($2).env.idx[($1).app.func]
    )
    ,arg(idx) AS (
        SELECT ($2).env.idx[($1).app.arg]
    )
    ,t(celem) AS(
        SELECT
            ($2).closure.elems[idx]
        FROM
            func
    )
    SELECT
        machine(
            (celem).code
            ,env(
                arg.idx || (celem).env.idx
            )
            ,dump(
                dump_elem(
                    consume(($2).code)
                    ,($2).env
                )
                || ($2).dump.elems
            )
            ,($2).closure
        )
    FROM
        t,arg
$$ LANGUAGE SQL IMMUTABLE STRICT
;

-- return from function
CREATE OR REPLACE FUNCTION ret (Machine) RETURNS Machine AS $$
    WITH t(dump) AS (
        SELECT
            ($1).dump.elems[1]
    )
    SELECT
        machine(
            (dump).code
            ,env(
                ($1).env.idx[1]
                || (dump).env.idx
            )
            ,consume(($1).dump)
            ,($1).closure
        )
    FROM
        t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

-- succ: increment ascii code
CREATE OR REPLACE FUNCTION exec_succ (Machine) RETURNS Machine AS $$
    WITH t (new_ascii) AS (
        SELECT (get_ascii($1) + 1) % 256
    )
    SELECT
        ret(
            machine(
                consume(($1).code)
                ,env(
                    ARRAY[ (array_length(($1).closure.elems,1)+1) ]
                )
                ,($1).dump
                ,closure(
                    ($1).closure.elems
                    || char_closure_elem( new_ascii )
                )
            )
        )
    FROM
        t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

/*
 * For debug
 */
-- dummy function to define co-recursive function
CREATE OR REPLACE FUNCTION debug_tree (Tree, depth Int) RETURNS Text AS $$
    SELECT ''::Text;
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_trees (Tree[], depth Int) RETURNS Text AS $$
    SELECT
        CASE
            WHEN array_length($1,1) > 0 THEN '' || array_to_string(array_agg(txt), E'\n') || ''
            ELSE '[]'
        END
    FROM(
        SELECT
            debug_tree(tree(nodes), $2) AS txt
        FROM
            unnest($1) AS t(nodes)
    )t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_tree (Tree, depth Int) RETURNS Text AS $$
    SELECT
        CASE (root).op
            WHEN 'Abs' THEN repeat(E'\t',$2) || E'Abs\n' || debug_trees(subtrees($1), $2+1) || E'\n'
            WHEN 'App' THEN repeat(E'\t',$2) || 'App(' || 'func:' || (root).app.func || ',arg:' || (root).app.arg || E')'
            WHEN 'Char' THEN 'Char(' || (root).ascii || ')'
            ELSE (root).op::Text
        END
    FROM(
        SELECT root($1) AS root
    )t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_code (Code) RETURNS Text AS $$
    SELECT debug_trees(($1).trees, 0);
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_env (Env) RETURNS Text AS $$
    SELECT '[' || array_to_string(($1).idx, ',') || ']'
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_dumpelem (DumpElem) RETURNS Text AS $$
    SELECT
        '(code:' || debug_code(($1).code) || ','
        || 'env:' || debug_env(($1).env) || ')'
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_dump (Dump) RETURNS Text AS $$
    SELECT
        CASE
            WHEN NOT isEmpty($1) THEN '[' || array_to_string(array_agg(txt), ',') || ']'
            ELSE '[]'
        END
    FROM(
        SELECT
            debug_dumpelem(dump_elem(code,env)) AS txt
        FROM
            unnest(($1).elems) AS t(code, env)
    )t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_closureelem (ClosureElem) RETURNS Text AS $$
    SELECT
        '(code:' || debug_code(($1).code) || ','
        || 'env:' || debug_env(($1).env) || ')'
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_closure (Closure) RETURNS Text AS $$
    SELECT
        '[' || array_to_string(array_agg(txt), ',') || ']'
    FROM(
        SELECT
            debug_closureelem(closure_elem(code,env)) AS txt
        FROM
            unnest(($1).elems) AS t(code, env)
    )t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

CREATE OR REPLACE FUNCTION debug_machine (Machine) RETURNS Text AS $$
    SELECT
        'code:' || debug_code(($1).code) || E'\n'
        || 'env:' || debug_env(($1).env) || E'\n'
        || 'dump:' || debug_dump(($1).dump) || E'\n'
        || 'closure:' || debug_closure(($1).closure)
$$ LANGUAGE SQL IMMUTABLE STRICT
;

/*
 * Execute
 */
CREATE OR REPLACE FUNCTION exec (Code) RETURNS Text AS $$
WITH RECURSIVE
init(machine) AS (
    SELECT
    machine(
        $1
        ,env( ARRAY[ 4,3,2,1 ] )
        ,dump(
            ARRAY[
                dump_elem(
                    code( ARRAY[ tree( ARRAY[app_node(1,2,(1,1))] ) ] )
                    ,env( ARRAY[ ]::Int[] )
                )
                ,dump_elem(
                    code( ARRAY[ tree( ARRAY[]::Node[] ) ] )
                    ,env( ARRAY[ ]::Int[] )
                )
            ]
        )
        ,closure(
            ARRAY[
                closure_elem(
                    code( ARRAY[ tree( ARRAY[in_node()] ) ] )
                    ,env( ARRAY[ ]::Int[] )
                )
                ,closure_elem(
                    code( ARRAY[ tree( ARRAY[char_node(119)] ) ] )
                    ,env( ARRAY[ ]::Int[] )
                )
                ,closure_elem(
                    code( ARRAY[ tree( ARRAY[succ_node()] ) ] )
                    ,env( ARRAY[ ]::Int[] )
                )
                ,closure_elem(
                    code( ARRAY[ tree( ARRAY[out_node()] ) ] )
                    ,env( ARRAY[ ]::Int[] )
                )
            ]
        )
    )
)
,eval (idx, machine, output) AS (
    (
        WITH sub (tree) AS (
            SELECT
                (machine).code.trees[1]
            FROM
                init
        )
        SELECT
            1::Int AS idx
            ,machine
            ,''::Text
        FROM
            init,sub
    )
    UNION ALL(
        WITH
        prev(idx, machine) AS (
            SELECT
                idx
                ,machine
                ,output
            FROM
                eval
            LIMIT 1
        )
        ,sub(idx, tree, root) AS (
            SELECT
                idx
                ,tree
                ,root(tree)
            FROM(
                SELECT
                    idx
                    ,(machine).code.trees[1] AS tree
                FROM
                    prev
            )t
        )
        SELECT
            idx + 1
            ,CASE
                WHEN isEmpty((machine).code) THEN ret(machine)
                WHEN (sub.root).op = 'Abs' THEN exec_abs(subtrees(sub.tree), machine)
                WHEN (sub.root).op = 'App' THEN exec_app(sub.root, machine)
                WHEN (sub.root).op = 'Out' THEN ret(machine)
                WHEN (sub.root).op = 'Succ' THEN exec_succ(machine)
            END
            ,CASE
                WHEN (sub.root).op = 'Out' THEN output || get_char(machine)
                ELSE output
            END
        FROM
            prev
        INNER JOIN -- 直前以外のprevとJOINされてしまうためINNER JOINを行う
            sub USING(idx)
        WHERE
            NOT (isEmpty((machine).code) AND isEmpty((machine).dump))
    )
)
SELECT
    output
FROM
    eval
WHERE
    output IS NOT NULL
ORDER BY
    idx DESC
LIMIT 1
$$ LANGUAGE SQL IMMUTABLE STRICT
;

/*
 * Parse and build tree
 */
CREATE OR REPLACE FUNCTION add_node (Tree, Node) RETURNS Tree AS $$
    SELECT
        tree(
            array_agg(
                node(
                    CASE WHEN l >= ($2).l THEN l + 2 ELSE l END
                    ,CASE WHEN r >= ($2).l THEN r + 2 ELSE r END
                    ,op
                    ,app
                    ,ascii)
            ) || $2
        )
    FROM
        unnest($1.nodes) AS t(l,r,op,app,ascii)
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION add_abs_node_n_times (Tree, Int) RETURNS Tree AS $$
    WITH RECURSIVE rec(tree, nextl, num) AS (
        SELECT
            $1
            ,COALESCE(max(l), 0) + 1
            ,0
        FROM
            unnest($1.nodes) AS t(l,r,op,app,ascii)
        UNION ALL
        SELECT
            add_node(tree, abs_node(nextl,nextl+1))
            ,nextl+1
            ,num+1
        FROM
            rec
        WHERE
            num < $2
    )
    SELECT
        tree
    FROM
        rec
    ORDER BY
        num DESC
    LIMIT 1
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION build_tree (Text) RETURNS tree AS $$
WITH RECURSIVE
src(chr, len) AS (
    SELECT
        array_agg(substring(s[1] from 1 for 1))
        ,array_agg(char_length(s[1]))
    FROM
        regexp_matches($1, '(w+|W+)', 'g') AS t(s)
)
,rec(tree, idx, nextl) AS (
    SELECT
        tree( ARRAY[]::Node[] )::Tree
        ,1::Int
        ,1::Int
    UNION ALL
    SELECT
        CASE chr[idx]
            WHEN 'w' THEN add_abs_node_n_times(tree, len[idx])
            WHEN 'W' THEN add_node(tree, app_node(nextl,nextl+1,(len[idx],len[idx+1])))
        END
        ,CASE chr[idx]
            WHEN 'w' THEN idx + 1
            WHEN 'W' THEN idx + 2
        END
        ,CASE chr[idx]
            WHEN 'w' THEN nextl + len[idx]
            WHEN 'W' THEN nextl + 2
        END
    FROM
        rec, src
    WHERE
        idx <= array_length(chr, 1)
)
SELECT
    tree
FROM
    rec
ORDER BY
    idx DESC
LIMIT 1
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION sanitize_source (Text) RETURNS Text AS $$
    SELECT 
        regexp_replace(
            regexp_replace(
                $1, '^[^w]*', ''
            )
            ,'[^wWv]', '', 'g'
        )
$$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION parse (Text) RETURNS code AS $$
SELECT
    code( array_agg( build_tree(src) ) )
FROM
    unnest(
        string_to_array(
            sanitize_source($1)
            ,'v'
        )
    ) AS t(src)
WHERE
    src <> ''
$$ LANGUAGE SQL
;


CREATE OR REPLACE FUNCTION run_grass (Text) RETURNS text AS $$
SELECT
    exec( parse($1) )
$$ LANGUAGE SQL
;
