# GRASS ON SQL

Implementaion of [Grass Language](http://www.blue.sky.or.jp/grass/) with Pure SQL on PostgreSQL

([Homuhomu](http://d.hatena.ne.jp/yuroyoro/20110601/1306908421) is also implemented)

## Interface

FUNCTION run_grass(text) RETURNS text;
FUNCTION run_homu(text) RETURNS text;

## Usage

psql -f grass.sql

## Example

    SELECT run_grass('wWWwwww');

     run_grass 
    -----------
     w
    (1 row)

-------------------------------

    SELECT run_grass('wwWWwv wwwwWWWwwWwwWWWWWWwwwwWwwv wWWwwwWwwwwWwwwwwwWwwwwwwwww');

     run_grass 
    -----------
     ww
    (1 row)

-------------------------------

    SELECT run_grass('wWWWwwwwWWWw');

     run_grass 
    -----------
     x
    (1 row)

-------------------------------

    SELECT
        run_grass($$
            wWWWwWWWWwv wWWwWWWwv wWWwWWWwv wWWwWWWwv wWWwWWWwv wWWwWWWwv
            wWWwWWWwv wWWwwwwwwwwwwwWWWWWwWWWWWwWWWWWWWWwWWWWWWWWWWWWWWwWWWWWWWWWW
            WWwWWWWWWWWWWWWWWwwWWWWWWWWWWWWWwWWWWWWWWWWWWWWwwwwwWWWWWWWWWWWWWWWwww
            wwwwWWWWWWWWWWWWWWWWWwWWWWWWWWWWWWWWWWWWWwWWWWWWWWWWWWWWWWWWWWWWwwWWWW
            WWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWwWWWWWWWWWWWWWWWWWW
            WWwwWWWWWWWWWWWWWWWWWWWWWWWwWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwwwwwW
            WWWWWWWWWWWWWWWWWWWWWWWwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwwwwww
            wwWWWWWWWWWWWWWWWWWWWWWWWwWWWWWWWWWWWWWWWWWWWWWWWWWWwWWWWWWWWWWWWWWWWW
            WWWWWWWWWWWWWWwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwWWWWWWWWWWW
            WWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
            WWWWWwwwwwwwwwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwww
            wwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwWWWWWWWWWWWWWWW
            WWWWWWWWWWWWWWWWWWWWWWwwwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
            WWWWwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWW
            WWWWWWWWWWWWWwwwwwwwwwwwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
            WWWWWwwwwwwwwwwwwwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
            wwwwwwwwwwwwwwwwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWw
            wwwwwwwwwwwwwwwwwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWwwwwwww
            wwwwwwwwwv
        $$)
    ;
       run_grass   
    ---------------
     Hello, world!


-------------------------------
    SELECT
        run_homu($$
            ほむ ほむほむほむ ほむ ほむほむほむほむ ほむ
            ほむ ほむほむ ほむ ほむほむほむ ほむ
            ほむ ほむほむ ほむ ほむほむほむ ほむ
            ほむ ほむほむ ほむ ほむほむほむ ほむ
            ほむ ほむほむ ほむ ほむほむほむ ほむ
            ほむ ほむほむ ほむ ほむほむほむ ほむ
            ほむ ほむほむ ほむ ほむほむほむ ほむ
            ほむ ほむほむ ほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむ ほむ ほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ ほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむほむ
        $$)
    ;
       run_homu    
    ---------------
     Hello, world!
    (1 row)
