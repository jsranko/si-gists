-- UDTF:VIEW_DEPENDENCIES determines view dependencies


Create or Replace Function VIEW_DEPENDENCIES(File Varchar(10), 
                                             Library Varchar(10))
Returns Table (Level Integer, 
               File Varchar(10),
               Library Varchar(10))
Language Sql
Specific VIEWDEPS
Not Deterministic
No External Action
Returns Null On Null Input
Set Option Dbgview = *Source
Begin Atomic

Return 
With Recursive Dependents (calllevel, dbffil, dbflib, dbffdp, dbfldp) As (
          Select 1 As calllevel , dbffil , dbflib , dbffdp , dbfldp 
            From qadbfdep 
           Where dbffil = File And dbflib = Library 
           Union All 
          Select calllevel + 1 As calllevel, b.dbffil, b.dbflib, b.dbffdp, b.dbfldp 
            From Dependents a 
            Join qadbfdep b 
              On (a.dbffdp, a.dbfldp) = (b.dbffil, b.dbflib) 
), dependencies As (
          Select calllevel, dbffil, dbflib, dbffdp, dbfldp 
            From Dependents
        Group By calllevel, dbffil, dbflib, dbffdp, dbfldp 
        Order By calllevel, dbffil Asc
), uni As (
          Select calllevel, dbffil, dbflib 
            From dependencies
           Union    
          Select calllevel, dbffdp, dbfldp 
            From dependencies a
           Where Not Exists (Select * From dependencies b Where (b.dbffil, b.dbflib) = (a.dbffdp, a.dbfldp))
)
          Select *
            From uni
        Order By calllevel, dbffil
;
End
;
-- Run it
                               
select * from table(VIEW_DEPENDENCIES('SYSVIEWS', 'QSYS2')) as a
;