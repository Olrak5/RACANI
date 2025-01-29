#include <vector>
#include <string>
#include <cstring>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <glm/glm.hpp>

#ifndef CPLOADER_HPP
#define CPLOADER_HPP

bool loadCPs(
	const char * path, 
	std::vector<glm::vec3> & control_points
);

#endif