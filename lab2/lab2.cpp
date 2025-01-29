// Include standard headers
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <math.h>
#include <algorithm>

// Include GLEW
#include <GL/glew.h>

// Include GLFW
#include <GLFW/glfw3.h>
GLFWwindow* window;

// Include GLM
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/quaternion.hpp>
#include <glm/gtx/quaternion.hpp>
#include <glm/gtx/euler_angles.hpp>
#include <glm/gtx/norm.hpp>

#include <glm/ext.hpp>
#include <glm/gtx/string_cast.hpp>

#include <iostream>

using namespace glm;

#include <headers/shader.hpp>
#include <headers/texture.hpp>
#include <headers/controls.hpp>
#include <headers/objloader.hpp>
#include <headers/bspline.hpp>
#include <headers/cploader.hpp>



struct Particle{
	glm::vec3 pos, speed;
	unsigned char r,g,b,a; // Color
	float size, angle, weight;
	float life; // Remaining life of the particle. if <0 : dead and unused.
	float cameradistance; // *Squared* distance to the camera. if dead : -1.0f

	bool operator<(const Particle& that) const {
		// Sort in reverse order : far particles drawn first.
		return this->cameradistance > that.cameradistance;
	}
};

const int MaxParticles = 100;
Particle ParticlesContainer[MaxParticles];
int LastUsedParticle = 0;

// Finds a Particle in ParticlesContainer which isn't used yet.
// (i.e. life < 0);
int FindUnusedParticle(){

	for(int i=LastUsedParticle; i<MaxParticles; i++){
		if (ParticlesContainer[i].life < 0){
			LastUsedParticle = i;
			return i;
		}
	}

	for(int i=0; i<LastUsedParticle; i++){
		if (ParticlesContainer[i].life < 0){
			LastUsedParticle = i;
			return i;
		}
	}

	return 0; // All particles are taken, override the first one
}

void SortParticles(){
	std::sort(&ParticlesContainer[0], &ParticlesContainer[MaxParticles]);
}



int main( int argc, char *argv[] )
{
	// Initialize GLFW
	if( !glfwInit() )
	{
		fprintf( stderr, "Failed to initialize GLFW\n" );
		getchar();
		return -1;
	}

	glfwWindowHint(GLFW_SAMPLES, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // To make macOS happy; should not be needed
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	// Open a window and create its OpenGL context
	window = glfwCreateWindow( 1024, 768, "Lab1", NULL, NULL);
	if( window == NULL ){
		fprintf( stderr, "Failed to open GLFW window. If you have an Intel GPU, they are not 3.3 compatible. Try the 2.1 version of the tutorials.\n" );
		getchar();
		glfwTerminate();
		return -1;
	}
	glfwMakeContextCurrent(window);

	// Initialize GLEW
	glewExperimental = true; // Needed for core profile
	if (glewInit() != GLEW_OK) {
		fprintf(stderr, "Failed to initialize GLEW\n");
		getchar();
		glfwTerminate();
		return -1;
	}

	// Ensure we can capture the escape key being pressed below
	glfwSetInputMode(window, GLFW_STICKY_KEYS, GL_TRUE);    

	// Dark blue background
	// glClearColor(0.0f, 0.0f, 0.4f, 0.0f);

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

	// Enable depth test
	glEnable(GL_DEPTH_TEST);
	// Accept fragment if it is closer to the camera than the former one
	glDepthFunc(GL_LESS); 

	// Cull triangles which normal is not towards the camera
	glEnable(GL_CULL_FACE);

	GLuint VertexArrayID;
	glGenVertexArrays(1, &VertexArrayID);
	glBindVertexArray(VertexArrayID);

	// Create and compile our GLSL program from the shaders
	// GLuint programID = LoadShaders( "shaders/TransformVertexShader.vertexshader", "shaders/ColorFragmentShader.fragmentshader" );
    GLuint programID = LoadShaders( "shaders/StandardShading.vertexshader", "shaders/StandardShading.fragmentshader" );
    // GLuint programID = LoadShaders( "shaders/Particle.vertexshader", "shaders/Particle.fragmentshader" );
    GLuint programIDParticle = LoadShaders( "shaders/Particle.vertexshader", "shaders/Particle.fragmentshader" );


    // Vertex shader
	GLuint CameraRight_worldspace_ID  = glGetUniformLocation(programIDParticle, "CameraRight_worldspace");
	GLuint CameraUp_worldspace_ID  = glGetUniformLocation(programIDParticle, "CameraUp_worldspace");
	GLuint ViewProjMatrixID = glGetUniformLocation(programIDParticle, "VP");

	// fragment shader
	GLuint TextureID  = glGetUniformLocation(programIDParticle, "myTextureSampler");



    static GLfloat* g_particule_position_size_data = new GLfloat[MaxParticles * 4];
	static GLubyte* g_particule_color_data         = new GLubyte[MaxParticles * 4];

	for(int i=0; i<MaxParticles; i++){
		ParticlesContainer[i].life = -1.0f;
		ParticlesContainer[i].cameradistance = -1.0f;
	}


    char * imagePath = argv[1];

    // printf("%s\n", argv[2]);

    FILE * file = fopen(imagePath, "r");
    fclose(file);
    GLuint Texture = loadBMP_custom(imagePath);

    static const GLfloat g_vertex_buffer_data[] = { 
		 -0.5f, -0.5f, 0.0f,
		  0.5f, -0.5f, 0.0f,
		 -0.5f,  0.5f, 0.0f,
		  0.5f,  0.5f, 0.0f,
	};


    GLuint billboard_vertex_buffer;
	glGenBuffers(1, &billboard_vertex_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, billboard_vertex_buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(g_vertex_buffer_data), g_vertex_buffer_data, GL_STATIC_DRAW);

	// The VBO containing the positions and sizes of the particles
	GLuint particles_position_buffer;
	glGenBuffers(1, &particles_position_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, particles_position_buffer);
	// Initialize with empty (NULL) buffer : it will be updated later, each frame.
	glBufferData(GL_ARRAY_BUFFER, MaxParticles * 4 * sizeof(GLfloat), NULL, GL_STREAM_DRAW);

	// The VBO containing the colors of the particles
	GLuint particles_color_buffer;
	glGenBuffers(1, &particles_color_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, particles_color_buffer);
	// Initialize with empty (NULL) buffer : it will be updated later, each frame.
	glBufferData(GL_ARRAY_BUFFER, MaxParticles * 4 * sizeof(GLubyte), NULL, GL_STREAM_DRAW);

    // Get a handle for our "MVP" uniform
	GLuint MatrixID = glGetUniformLocation(programID, "MVP");
	GLuint ViewMatrixID = glGetUniformLocation(programID, "V");
	GLuint ModelMatrixID = glGetUniformLocation(programID, "M");

	// Projection matrix : 45� Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
	glm::mat4 Projection = glm::perspective(glm::radians(45.0f), 4.0f / 3.0f, 0.1f, 100.0f);
	// Camera matrix
	glm::mat4 View       = glm::lookAt(
								glm::vec3(2,2,6), // Camera is at (4,3,-3), in World Space
								glm::vec3(0,0,0), // and looks at the origin
								glm::vec3(0,0,1)  // Head is up (set to 0,-1,0 to look upside-down)
						   );

    float control_points[] = { 
		0.0f,   0.0f,   0.0f,
        0.0f,   10.0f,  5.0f,
        10.0f,  10.0f,  10.0f,
        10.0f,  0.0f,   15.0f,
        0.0f,   0.0f,   20.0f,
        0.0f,   10.0f,  25.0f,
        10.0f,  10.0f,  30.0f,
        10.0f,  0.0f,   35.0f,
        0.0f,   0.0f,   40.0f,
        0.0f,   10.0f,  45.0f,
        10.0f,  10.0f,  50.0f,
        10.0f,  0.0f,   55.0f
	};

    int num_cp = 12;
    // int num_cp = control_points.size();

    int spline_resolution = 20000;
    int num_steps = 100;
    float tan_scale = 0.3f;

    bSpline bSpline(control_points, num_cp);

    std::vector<glm::vec3> bspline_points;
    std::vector<glm::vec3> locations;
    std::vector<glm::vec3> tangents;
    std::vector<glm::vec3> draw_tangents;
    std::vector<glm::vec3> os;
    std::vector<float> fi;
    std::vector<glm::vec3> normals;
    std::vector<glm::vec3> binormals;
    std::vector<glm::mat3> DCMs;
    
    bSpline.getBSplinePoints(bspline_points, spline_resolution);
    bSpline.getLocationsTangents(locations, tangents, draw_tangents, num_steps, tan_scale, os, fi, normals, binormals, DCMs);


    GLuint splinebuffer;
	glGenBuffers(1, &splinebuffer);
	glBindBuffer(GL_ARRAY_BUFFER, splinebuffer);
	glBufferData(GL_ARRAY_BUFFER, bspline_points.size() * sizeof(glm::vec3), &bspline_points[0], GL_STATIC_DRAW);



    vec3 EulerAngles(0, 0, 0);
    quat quaternion = quat(EulerAngles);

    glm::mat4 Traslation = glm::translate(glm::mat4(1.0), glm::vec3(0.0f, 0.0f, 0.0f));
    glm::mat4 Rotation = glm::toMat4(quaternion);
    // glm::mat4 Scale = glm::scale(glm::mat4(1), glm::vec3(0.3f));
    glm::mat4 Scale = glm::scale(glm::mat4(1), glm::vec3(1));

    glm::mat4 Model = Traslation * Rotation * Scale;

    glm::mat4 MVP = Projection * View * Model;

    // std::cout << glm::to_string(Model) << std::endl;

    int i = 0;
    // float j = 0;

    // Model = mat4(1.0f); 





    double lastTime = glfwGetTime();
	do{
        
        i++;
        i%=locations.size();

		// Clear the screen
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);




        double currentTime = glfwGetTime();
		double delta = currentTime - lastTime;
		lastTime = currentTime;


		glm::vec3 CameraPosition(glm::inverse(View)[3]);

		glm::mat4 ViewProjectionMatrix = Projection * View;



        int part_count = 200.0;
		int newparticles = (int)(delta*part_count);
		if (newparticles > (int)(0.016f*part_count))
			newparticles = (int)(0.016f*part_count);
		
		for(int j=0; j<newparticles; j++){
			int particleIndex = FindUnusedParticle();
			ParticlesContainer[particleIndex].life = 1.0f; 
			ParticlesContainer[particleIndex].pos = locations[i];

			float spread = 0.8f;
            // glm::vec3 maindir = normals[i];
            glm::vec3 maindir = glm::vec3(0.0f, 0.0f, 1.0f);
            int dir_scale = 1000;
			glm::vec3 randomdir = glm::vec3(
				(rand()%(2*dir_scale) - 1.0f*dir_scale)/(1.0f*dir_scale),
				(rand()%(2*dir_scale) - 1.0f*dir_scale)/(1.0f*dir_scale),
				(rand()%(2*dir_scale) - 1.0f*dir_scale)/(1.0f*dir_scale)
			);
			
			ParticlesContainer[particleIndex].speed = maindir + randomdir*spread;

			ParticlesContainer[particleIndex].r = rand() % 256;
			ParticlesContainer[particleIndex].g = rand() % 256;
			ParticlesContainer[particleIndex].b = rand() % 256;
			ParticlesContainer[particleIndex].a = (rand() % 256) / 3;

			// ParticlesContainer[particleIndex].size = (rand()%1000)/2000.0f + 0.1f;

            ParticlesContainer[particleIndex].size = 0.2f;
			
		}

        int part_count_2 = part_count;        
		int newparticles_2 = (int)(delta*part_count_2);
		if (newparticles_2 > (int)(0.016f*part_count_2))
			newparticles_2 = (int)(0.016f*part_count_2);
		
		for(int j=0; j<newparticles_2; j++){
			int particleIndex = FindUnusedParticle();
			ParticlesContainer[particleIndex].life = 1.0f; 
			ParticlesContainer[particleIndex].pos = vec3(0,0,0);

			float spread = 0.2f;
            // glm::vec3 maindir = normals[i];
            glm::vec3 maindir = glm::vec3(0.0f, 0.0f, 1.0f);
            int dir_scale = 1000;
			glm::vec3 randomdir = glm::vec3(
				(rand()%(2*dir_scale) - 1.0f*dir_scale)/(1.0f*dir_scale),
				(rand()%(2*dir_scale) - 1.0f*dir_scale)/(1.0f*dir_scale),
				(rand()%(2*dir_scale) - 1.0f*dir_scale)/(1.0f*dir_scale)
			);
			
			ParticlesContainer[particleIndex].speed = maindir + randomdir*spread;

			ParticlesContainer[particleIndex].r = rand() % 256;
			ParticlesContainer[particleIndex].g = rand() % 256;
			ParticlesContainer[particleIndex].b = rand() % 256;
			ParticlesContainer[particleIndex].a = (rand() % 256) / 3;

			// ParticlesContainer[particleIndex].size = (rand()%1000)/2000.0f + 0.1f;

            ParticlesContainer[particleIndex].size = 0.2f;
			
		}



		int ParticlesCount = 0;
		for(int i=0; i<MaxParticles; i++){

			Particle& p = ParticlesContainer[i]; 

			if(p.life > 0.0f){

				p.life -= delta;
				if (p.life > 0.0f){

					p.speed += glm::vec3(0.0f, 0.0f, -9.81f) * (float)delta * 0.5f;
					p.pos += p.speed * (float)delta;
					p.cameradistance = glm::length2( p.pos - CameraPosition );
					//ParticlesContainer[i].pos += glm::vec3(0.0f,10.0f, 0.0f) * (float)delta;

					g_particule_position_size_data[4*ParticlesCount+0] = p.pos.x;
					g_particule_position_size_data[4*ParticlesCount+1] = p.pos.y;
					g_particule_position_size_data[4*ParticlesCount+2] = p.pos.z;

                    p.size *= 0.99f;
												   
					g_particule_position_size_data[4*ParticlesCount+3] = p.size;
												   
					g_particule_color_data[4*ParticlesCount+0] = p.r;
					g_particule_color_data[4*ParticlesCount+1] = p.g;
					g_particule_color_data[4*ParticlesCount+2] = p.b;
					g_particule_color_data[4*ParticlesCount+3] = p.a;

				}else{
					p.cameradistance = -1.0f;
				}

				ParticlesCount++;

			}
		}

		SortParticles();

		glBindBuffer(GL_ARRAY_BUFFER, particles_position_buffer);
		glBufferData(GL_ARRAY_BUFFER, MaxParticles * 4 * sizeof(GLfloat), NULL, GL_STREAM_DRAW); // Buffer orphaning, a common way to improve streaming perf. See above link for details.
		glBufferSubData(GL_ARRAY_BUFFER, 0, ParticlesCount * sizeof(GLfloat) * 4, g_particule_position_size_data);

		glBindBuffer(GL_ARRAY_BUFFER, particles_color_buffer);
		glBufferData(GL_ARRAY_BUFFER, MaxParticles * 4 * sizeof(GLubyte), NULL, GL_STREAM_DRAW); // Buffer orphaning, a common way to improve streaming perf. See above link for details.
		glBufferSubData(GL_ARRAY_BUFFER, 0, ParticlesCount * sizeof(GLubyte) * 4, g_particule_color_data);

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glUseProgram(programIDParticle);

		// Bind our texture in Texture Unit 0
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, Texture);
		// Set our "myTextureSampler" sampler to use Texture Unit 0
		glUniform1i(TextureID, 0);

		// Same as the billboards tutorial
		glUniform3f(CameraRight_worldspace_ID, View[0][0], View[1][0], View[2][0]);
		glUniform3f(CameraUp_worldspace_ID   , View[0][1], View[1][1], View[2][1]);

		glUniformMatrix4fv(ViewProjMatrixID, 1, GL_FALSE, &ViewProjectionMatrix[0][0]);

		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, billboard_vertex_buffer);
		glVertexAttribPointer(
			0,                  // attribute. No particular reason for 0, but must match the layout in the shader.
			3,                  // size
			GL_FLOAT,           // type
			GL_FALSE,           // normalized?
			0,                  // stride
			(void*)0            // array buffer offset
		);
		

		glEnableVertexAttribArray(1);
		glBindBuffer(GL_ARRAY_BUFFER, particles_position_buffer);
		glVertexAttribPointer(
			1,                                // attribute. No particular reason for 1, but must match the layout in the shader.
			4,                                // size : x + y + z + size => 4
			GL_FLOAT,                         // type
			GL_FALSE,                         // normalized?
			0,                                // stride
			(void*)0                          // array buffer offset
		);


		glEnableVertexAttribArray(2);
		glBindBuffer(GL_ARRAY_BUFFER, particles_color_buffer);
		glVertexAttribPointer(
			2,                                // attribute. No particular reason for 1, but must match the layout in the shader.
			4,                                // size : r + g + b + a => 4
			GL_UNSIGNED_BYTE,                 // type
			GL_TRUE,                          // normalized?    *** YES, this means that the unsigned char[4] will be accessible with a vec4 (floats) in the shader ***
			0,                                // stride
			(void*)0                          // array buffer offset
		);

		glVertexAttribDivisor(0, 0); // particles vertices : always reuse the same 4 vertices -> 0
		glVertexAttribDivisor(1, 1); // positions : one per quad (its center)                 -> 1
		glVertexAttribDivisor(2, 1); // color : one per quad                                  -> 1

		glDrawArraysInstanced(GL_TRIANGLE_STRIP, 0, 4, ParticlesCount);

		glDisableVertexAttribArray(0);
		glDisableVertexAttribArray(1);
		glDisableVertexAttribArray(2);

        
        glDisable(GL_BLEND);


      

        glUseProgram(programID);

        
		glUniformMatrix4fv(MatrixID, 1, GL_FALSE, &MVP[0][0]);
		glUniformMatrix4fv(ModelMatrixID, 1, GL_FALSE, &Model[0][0]);
		glUniformMatrix4fv(ViewMatrixID, 1, GL_FALSE, &View[0][0]);

        glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, splinebuffer);
		glVertexAttribPointer(
			0,                                // attribute
			3,                                // size
			GL_FLOAT,                         // type
			GL_FALSE,                         // normalized?
			0,                                // stride
			(void*)0                          // array buffer offset
		);


        glDrawArrays(GL_LINE_STRIP, 0, bspline_points.size());

        
		glDisableVertexAttribArray(0);

		// Swap buffers
		glfwSwapBuffers(window);
		glfwPollEvents();

	} // Check if the ESC key was pressed or the window was closed
	while( glfwGetKey(window, GLFW_KEY_ESCAPE ) != GLFW_PRESS &&
		   glfwWindowShouldClose(window) == 0 );

        
	delete[] g_particule_position_size_data;

	glDeleteBuffers(1, &splinebuffer);
    glDeleteBuffers(1, &particles_color_buffer);
	glDeleteBuffers(1, &particles_position_buffer);
	glDeleteBuffers(1, &billboard_vertex_buffer);
	glDeleteProgram(programID);
    glDeleteProgram(programIDParticle);
	glDeleteTextures(1, &Texture);
	glDeleteVertexArrays(1, &VertexArrayID);

	// Close OpenGL window and terminate GLFW
	glfwTerminate();

	return 0;
}


