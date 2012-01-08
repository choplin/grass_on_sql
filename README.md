# GRASS ON SQL

Implementaion of [Grass Language](http://www.blue.sky.or.jp/grass/) with Pure SQL on PostgreSQL

## Interface

FUNCTION run_grass(text) RETURNS text;

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
