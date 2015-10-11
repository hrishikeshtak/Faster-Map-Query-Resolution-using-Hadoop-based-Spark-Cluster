#### OpenStreetMap (OSM)              
OpenStreetMap (OSM) is a collaborative project to create a free editable map of the world.  OpenStreetMap, the project that creates and distributes free geographic data for the world.      
Read about [OSM](https://wiki.openstreetmap.org/wiki/Main_Page)   

**Map Features :**  OpenStreetMap represents physical features on the ground (e.g., roads or buildings) using tags attached to its basic data structures (its nodes, ways, and relations). Each tag describes a geographic attribute of the feature being shown by that specific node, way or relation.          
Read more about [Map Features](https://wiki.openstreetmap.org/wiki/Map_Features)            

**Planet.osm :**  Planet.osm is the OpenStreetMap data in one file: all the nodes, ways and relations that make up our map.
More info about [Planet.osm](http://wiki.openstreetmap.org/wiki/Planet.osm)  
[Download the Planet.osm](http://download.geofabrik.de/) : download the osm.bz2 file and extract it using **bzip2 -dk denmark-latest.osm.bz2**

**OSM Tools :** 
> **Osm2pgsql :** osm2pgsql is a command-line based program that converts OpenStreetMap data to postGIS-enabled PostgreSQL databases.   
Read more about [osm2pgsql](http://wiki.openstreetmap.org/wiki/Osm2pgsql)           
check the schema of osm2pgsql [Osm2pgsql/schema](http://wiki.openstreetmap.org/wiki/Osm2pgsql/schema) 

**How to run script :**       
Download the .osm.bz2 file and extract in same directory and clone this repo and run       
**./install_osm2pgsql.py PATH-OF-OSM-FILE"**

**What do we have now?** :    
After success of script ( it will take long time as per size of OSM file )      
open **$psql database-name** from terminal then it will open psql prompt then type **\d** it will show tables

Schema |        Name        | Type  |  Owner        
--------+--------------------+-------+----------     
public | geography_columns  | view  | postgres          
public | geometry_columns    | view  | postgres    
public | planet_osm_line         | table | postgres        
public | planet_osm_nodes     | table | postgres         
public | planet_osm_point   | table | postgres         
public | planet_osm_polygon | table | postgres         
public | planet_osm_rels    | table | postgres            
public | planet_osm_roads   | table | postgres           
public | planet_osm_ways    | table | postgres             
public | raster_columns     | view  | postgres          
public | raster_overviews   | view  | postgres           
public | spatial_ref_sys    | table | postgres                


The tables that are imported contain many different types of information. Let me quickly go over them to give you a basic feeling of how the import happened:

- **planet_osm_line:** holds all non-closed pieces of geometry (called ways) at a high resolution. They mostly represent actual roads and are used when looking at a small, zoomed-in detail of a map.         

- **planet_osm_nodes:** an intermediate table that holds the raw point data (points in lat/long) with a corresponding "osm_id" to map them to other tables   

- **planet_osm_point:** holds all points-of-interest together with their OSM tags - tags that describe what they represent
- **planet_osm_polygon:** holds all closed piece of geometry (also called ways) like buildings, parks, lakes, areas, ...   

- **planet_osm_rels:** an intermediate table that holds extra connecting information about polygons     

- **planet_osm_roads:** holds lower resolution, non-closed piece of geometry in contrast with "planet_osm_line". This data is used when looking at a greater distance, covering much area and thus not much detail about smaller, local roads.   

- **planet_osm_ways:** an intermediate table which holds non-closed geometry in raw format

For more info about it check [link](http://shisaa.jp/postset/postgis-postgresqls-spatial-partner-part-3.html)