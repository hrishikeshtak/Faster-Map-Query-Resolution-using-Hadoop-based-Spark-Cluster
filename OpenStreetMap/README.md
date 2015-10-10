#### OpenStreetMap (OSM)              
OpenStreetMap (OSM) is a collaborative project to create a free editable map of the world.  OpenStreetMap, the project that creates and distributes free geographic data for the world.      
Read about [OSM](https://wiki.openstreetmap.org/wiki/Main_Page)   

**Map Features :**  OpenStreetMap represents physical features on the ground (e.g., roads or buildings) using tags attached to its basic data structures (its nodes, ways, and relations). Each tag describes a geographic attribute of the feature being shown by that specific node, way or relation.          
Read more about [Map Features](https://wiki.openstreetmap.org/wiki/Map_Features)            

**Planet.osm :**  Planet.osm is the OpenStreetMap data in one file: all the nodes, ways and relations that make up our map.
More info about [Planet.osm](http://wiki.openstreetmap.org/wiki/Planet.osm)  
[Download the Planet.osm](http://download.geofabrik.de/) : download the osm.bz2 file and extract it using bzip2 -dk **denmark-latest.osm.bz2**

**OSM Tools :** 
> **Osm2pgsql : ** osm2pgsql is a command-line based program that converts OpenStreetMap data to postGIS-enabled PostgreSQL databases.   
Read more about [osm2pgsql](http://wiki.openstreetmap.org/wiki/Osm2pgsql)           
check the schema of osm2pgsql [Osm2pgsql/schema](http://wiki.openstreetmap.org/wiki/Osm2pgsql/schema) 


**Note :** First setup Hadoop and spark    
**How to run script :**      
>**./draw_polygon.py Region_Syddanmark.txt 2000**