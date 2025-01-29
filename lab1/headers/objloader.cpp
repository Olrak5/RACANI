#include <vector>
#include <stdio.h>
#include <string>
#include <cstring>

#include <glm/glm.hpp>

#include "objloader.hpp"

// Very, VERY simple OBJ loader.
// Here is a short list of features a real function would provide : 
// - Binary files. Reading a model should be just a few memcpy's away, not parsing a file at runtime. In short : OBJ is not very great.
// - Animations & bones (includes bones weights)
// - Multiple UVs
// - All attributes should be optional, not "forced"
// - More stable. Change a line in the OBJ file and it crashes.
// - More secure. Change another line and you can inject code.
// - Loading from memory, stream, etc

bool loadOBJ(
	const char * path, 
	std::vector<glm::vec3> & out_vertices,
	std::vector<glm::vec3> & out_normals
){
	printf("Loading OBJ file %s...\n", path);

	std::vector<unsigned int> vertexIndices;
	std::vector<glm::vec3> temp_vertices; 

	FILE * file = fopen(path, "r");
	if( file == NULL ){
		printf("Impossible to open the file ! Are you in the right path ? See Tutorial 1 for details\n");
		getchar();
		return false;
	}

    int j = 0;

    // glm::vec3 center = glm::vec3(0,0,0);

	while( 1 ){

		char lineHeader[128];
		// read the first word of the line
		int res = fscanf(file, "%s", lineHeader);
		if (res == EOF)
			break; // EOF = End Of File. Quit the loop.

		// else : parse lineHeader
		
		if ( strcmp( lineHeader, "v" ) == 0 ){
			glm::vec3 vertex;
			fscanf(file, "%f %f %f\n", &vertex.x, &vertex.y, &vertex.z );
			temp_vertices.push_back(vertex);
            // center += vertex;
            j++;
		}else if ( strcmp( lineHeader, "f" ) == 0 ){
			std::string vertex1, vertex2, vertex3;
            unsigned int vertexIndex[3];
            int matches = fscanf(file, "%d %d %d\n", &vertexIndex[0], &vertexIndex[1], &vertexIndex[2] );
			if (matches != 3){
				printf("File can't be read by our simple parser :-( Try exporting with other options\n");
				fclose(file);
				return false;
			}
			vertexIndices.push_back(vertexIndex[0]);
			vertexIndices.push_back(vertexIndex[1]);
			vertexIndices.push_back(vertexIndex[2]);
		}else{
			// Probably a comment, eat up the rest of the line
			char stupidBuffer[1000];
			fgets(stupidBuffer, 1000, file);
		}

	}

	std::vector<glm::vec3> normals[j];

    // center /= i;

    for( unsigned int i=0; i<vertexIndices.size(); i+=3 ){

		unsigned int vertexIndex0 = vertexIndices[i];
        unsigned int vertexIndex1 = vertexIndices[i+1];
        unsigned int vertexIndex2 = vertexIndices[i+2];
		
		glm::vec3 vertex0 = temp_vertices[ vertexIndex0-1 ];
        glm::vec3 vertex1 = temp_vertices[ vertexIndex1-1 ];
        glm::vec3 vertex2 = temp_vertices[ vertexIndex2-1 ];

        glm::vec3 normal = glm::normalize( glm::cross( vertex1-vertex0, vertex2-vertex0));

        // if(glm::dot(center, normal) > 0) normal = -normal;
        normals[vertexIndex0-1].push_back(normal);
        normals[vertexIndex1-1].push_back(normal);
        normals[vertexIndex2-1].push_back(normal);
		
		// out_normals.push_back(normal);
	
	}

    for( int i=0; i<j; i++ ){
        glm::vec3 new_normal = glm::vec3(0);
        while( !normals[i].empty() ){
            new_normal = new_normal + normals[i].back();
            normals[i].pop_back();
        }
        out_normals.push_back(normalize(new_normal));
    }



	// For each vertex of each triangle
	for( unsigned int i=0; i<vertexIndices.size(); i++ ){

		// Get the indices of its attributes
		unsigned int vertexIndex = vertexIndices[i];
		
		// Get the attributes thanks to the index
		glm::vec3 vertex = temp_vertices[ vertexIndex-1 ];
		
		// Put the attributes in buffers
		out_vertices.push_back(vertex);
	
	}
	fclose(file);
	return true;
}