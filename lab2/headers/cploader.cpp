#include "cploader.hpp"

bool loadCPs(
	const char * path, 
	std::vector<glm::vec3> & control_points
){
	printf("Loading CPs file %s...\n", path);

	FILE * file = fopen(path, "r");
	if( file == NULL ){
		printf("Impossible to open the file ! Are you in the right path ? See Tutorial 1 for details\n");
		getchar();
		return false;
	}

	while( 1 ){

		char lineHeader[128];
		// read the first word of the line
		int res = fscanf(file, "%s", lineHeader);
		if (res == EOF)
			break; // EOF = End Of File. Quit the loop.

		// else : parse lineHeader
        
		glm::vec3 vertex;
        fscanf(file, "%f %f %f\n", &vertex.x, &vertex.y, &vertex.z );
        control_points.push_back(vertex);
		
	}
	fclose(file);
	return true;
}