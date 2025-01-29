// Include standard headers
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <math.h>

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
    // Hide the mouse and enable unlimited movement
    // glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    
    // Set the mouse at the center of the screen
    // glfwPollEvents();
    // glfwSetCursorPos(window, 1024/2, 768/2);

	// Dark blue background
	glClearColor(0.0f, 0.0f, 0.4f, 0.0f);

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

    // Get a handle for our "MVP" uniform
	GLuint MatrixID = glGetUniformLocation(programID, "MVP");
	GLuint ViewMatrixID = glGetUniformLocation(programID, "V");
	GLuint ModelMatrixID = glGetUniformLocation(programID, "M");

	// Projection matrix : 45� Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
	glm::mat4 Projection = glm::perspective(glm::radians(45.0f), 4.0f / 3.0f, 0.1f, 100.0f);
	// Camera matrix
	glm::mat4 View       = glm::lookAt(
								glm::vec3(2,2,5), // Camera is at (4,3,-3), in World Space
								glm::vec3(0,0,0), // and looks at the origin
								glm::vec3(0,0,1)  // Head is up (set to 0,-1,0 to look upside-down)
						   );
	// Model matrix : an identity matrix (model will be at the origin)
	// glm::mat4 Model      = glm::mat4(1.0f);
	// Our ModelViewProjection : multiplication of our 3 matrices
	// glm::mat4 MVP        = Projection * View * Model; // Remember, matrix multiplication is the other way around

	// Read our .obj file
	std::vector<glm::vec3> vertices;
	std::vector<glm::vec3> face_normals;
	bool res = loadOBJ(argv[1], vertices, face_normals);

    if(!res){
        printf("load error");
        return 1;
    }

	// Load it into a VBO

	GLuint vertexbuffer;
	glGenBuffers(1, &vertexbuffer);
	glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
	glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(glm::vec3), &vertices[0], GL_STATIC_DRAW);
	// glBufferData(GL_ARRAY_BUFFER, sizeof(g_vertex_buffer_data), g_vertex_buffer_data, GL_STATIC_DRAW);

    GLuint normalbuffer;
	glGenBuffers(1, &normalbuffer);
	glBindBuffer(GL_ARRAY_BUFFER, normalbuffer);
	glBufferData(GL_ARRAY_BUFFER, face_normals.size() * sizeof(glm::vec3), &face_normals[0], GL_STATIC_DRAW);

    // Get a handle for our "LightPosition" uniform
	glUseProgram(programID);
	GLuint LightID = glGetUniformLocation(programID, "LightPosition_worldspace");

    // std::vector<glm::vec3> control_points;


    // res = loadCPs("control_points.txt",control_points);

    // if(!res){
    //     printf("load error");
    //     return 1;
    // }

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
    int num_steps = 1000;
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
    
    res = bSpline.getBSplinePoints(bspline_points, spline_resolution);
    res = bSpline.getLocationsTangents(locations, tangents, draw_tangents, num_steps, tan_scale, os, fi, normals, binormals, DCMs);

    // get


    // for(int i=0; i< bspline_points.size();i++){
    //     std::cout << glm::to_string(bspline_points[i]) << std::endl;
    //     std::cout << 'a' << std::endl;
    // }


    GLuint splinebuffer;
	glGenBuffers(1, &splinebuffer);
	glBindBuffer(GL_ARRAY_BUFFER, splinebuffer);
	glBufferData(GL_ARRAY_BUFFER, bspline_points.size() * sizeof(glm::vec3), &bspline_points[0], GL_STATIC_DRAW);

    GLuint tangentbuffer;
	glGenBuffers(1, &tangentbuffer);
	glBindBuffer(GL_ARRAY_BUFFER, tangentbuffer);
	glBufferData(GL_ARRAY_BUFFER, draw_tangents.size() * sizeof(glm::vec3), &draw_tangents[0], GL_STATIC_DRAW);


    vec3 EulerAngles(0, 0, 0);
    quat quaternion = quat(EulerAngles);

    glm::mat4 Traslation = glm::translate(glm::mat4(1.0), glm::vec3(0.0f, 0.0f, 0.0f));
    glm::mat4 Rotation = glm::toMat4(quaternion);
    glm::mat4 Scale = glm::scale(glm::mat4(1), glm::vec3(0.3f));

    glm::mat4 Model = Traslation * Rotation * Scale;

    // std::cout << glm::to_string(Model) << std::endl;

    int i = 0;
    // float j = 0;

    // Model = mat4(1.0f); 
	do{

		// Clear the screen
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		// Use our shader
		glUseProgram(programID);

		// // Compute the MVP matrix from keyboard and mouse input
		// computeMatricesFromInputs();
		// glm::mat4 ProjectionMatrix = getProjectionMatrix();
		// glm::mat4 ViewMatrix = getViewMatrix();
		// glm::mat4 ModelMatrix = glm::mat4(1.0);

        // for(int i=0; i<num_cp; i++){

        // }

        i++;
        i%=locations.size();
        // if(i%10==0) j++;

        Traslation = glm::translate(glm::mat4(1.0), locations[i]);

        // quaternion = quat(vec3(M_PI/180*j,M_PI/180*j,M_PI/180*j));

        // vec3 s = vec3(0,0,1);
        // vec3 e = tangents[i];
        // vec3 os = normalize(vec3(
        //     s[1] * e[2] - e[1] * s[2],
        //     -(s[0] * e[2] - e[0] * s[2]),
        //     s[0] * e[1] - s[1] * e[2]
        // ));

        // float fi = acos(dot(s,e)/(length(s)*length(e)));

        // quaternion = quat(vec3(0,0,0));
        // // quaternion = quat(tangents[i]);
        // Rotation = glm::toMat4(quaternion);

        // quaternion = glm::angleAxis(degrees(fi), os);
        // quaternion = glm::angleAxis(degrees(fi[i]), os[i]);
        // Rotation = glm::toMat4(quaternion);

        Rotation = mat4(glm::inverse(DCMs[i]));

        mat4 prerotate = mat4(mat3(
            0.0f, 0.0f, 1.0f,
            0.0f, -1.0f, 0.0f,
            1.0f, 0.0f, 0.0f
        ));


        Model = Traslation * Rotation * prerotate * Scale;

		glm::mat4 MVP = Projection * View * Model;

		// Send our transformation to the currently bound shader, 
		// in the "MVP" uniform
		glUniformMatrix4fv(MatrixID, 1, GL_FALSE, &MVP[0][0]);
		glUniformMatrix4fv(ModelMatrixID, 1, GL_FALSE, &Model[0][0]);
		glUniformMatrix4fv(ViewMatrixID, 1, GL_FALSE, &View[0][0]);

        glm::vec3 lightPos = glm::vec3(4,4,4);
		glUniform3f(LightID, lightPos.x, lightPos.y, lightPos.z);

		// 1rst attribute buffer : vertices
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
		glVertexAttribPointer(
			0,                  // attribute
			3,                  // size
			GL_FLOAT,           // type
			GL_FALSE,           // normalized?
			0,                  // stride
			(void*)0            // array buffer offset
		);

        glEnableVertexAttribArray(1);
		glBindBuffer(GL_ARRAY_BUFFER, normalbuffer);
		glVertexAttribPointer(
			1,                                // attribute
			3,                                // size
			GL_FLOAT,                         // type
			GL_TRUE,                         // normalized?
			0,                                // stride
			(void*)0                          // array buffer offset
		);

		// Draw the triangle !
		glDrawArrays(GL_TRIANGLES, 0, vertices.size() );
        // glDrawArrays(GL_TRIANGLES, 0, 12*3 );

        // glDrawPixels

		glDisableVertexAttribArray(0);
		glDisableVertexAttribArray(1);

        
        Traslation = glm::translate(glm::mat4(1.0), glm::vec3(0.f));

        // quaternion = quat(vec3(M_PI/180*j,M_PI/180*j,M_PI/180*j));

        quaternion = quat(vec3(0,0,0));
        Rotation = glm::toMat4(quaternion);
        Scale = glm::scale(glm::mat4(1), glm::vec3(1));

        Model = Traslation * Rotation * Scale;

		MVP = Projection * View * Model;

        
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


        glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, tangentbuffer);
		glVertexAttribPointer(
			0,                                // attribute
			3,                                // size
			GL_FLOAT,                         // type
			GL_FALSE,                         // normalized?
			0,                                // stride
			(void*)0                          // array buffer offset
		);


        glDrawArrays(GL_LINES, 0, draw_tangents.size());

        
		glDisableVertexAttribArray(0);


		// Swap buffers
		glfwSwapBuffers(window);
		glfwPollEvents();

	} // Check if the ESC key was pressed or the window was closed
	while( glfwGetKey(window, GLFW_KEY_ESCAPE ) != GLFW_PRESS &&
		   glfwWindowShouldClose(window) == 0 );

	// Cleanup VBO and shader
	glDeleteBuffers(1, &vertexbuffer);
	glDeleteBuffers(1, &normalbuffer);
	glDeleteProgram(programID);
	glDeleteVertexArrays(1, &VertexArrayID);

	// Close OpenGL window and terminate GLFW
	glfwTerminate();

	return 0;
}

