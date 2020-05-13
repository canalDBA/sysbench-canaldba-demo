#!/usr/bin/env sysbench

-- Modifying the commmand line parameters.
sysbench.cmdline.options = {
  table_structure = {"Table structure", "i int, v varchar(32)"},
  table_prefix = {"Table prefix", "t"},
  table_engine = {"Table engine", "InnoDB"},
}
-- Incremental global variable that we will use to create unique tables
table_no=0

-- Function to get a mysql connection
function get_conn()
 drv = sysbench.sql.driver()
 return drv:connect()
end

-- This function is called every time that we need to initialize a thread.
function thread_init()
 -- Every time that we initialize a thread we want to get a new
 -- mysql connection to use it.
 con = get_conn()
end

-- Prepare function.
function prepare()
 print("Preparing the benchmark.")
 con = get_conn()
 con:query("CREATE DATABASE sysbenchtest;")
end

-- Event function
function event( thread_id )
 io.write(".")
 table_no = table_no + 1
 con:query("CREATE TABLE " ..
   " sysbenchtest.".. sysbench.opt.table_prefix .. thread_id .. "_" .. table_no ..
   " (" .. sysbench.opt.table_structure .. ") " ..
   "engine=" .. sysbench.opt.table_engine .. ";")
end

-- Cleanup function
function cleanup()
 print("Cleaning up after the benchmark.")
 con = get_conn()
 con:query("DROP DATABASE sysbenchtest;")
end
