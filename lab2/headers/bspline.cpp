// Include standard headers
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <math.h>

// Include GLEW
#include <GL/glew.h>

// Include GLM
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
using namespace glm;

#include <iostream>
#include <glm/ext.hpp>
#include <glm/gtx/string_cast.hpp>

#include "bspline.hpp"

bSpline::bSpline(float make_control_points[], int make_num_cp){
    num_cp = make_num_cp;
    for(int i=0;i<num_cp;i++){
        glm::vec3 point = glm::vec3(
                make_control_points[3*i],
                make_control_points[3*i+1],
                make_control_points[3*i+2]
            );
        control_points.push_back(point);
    }
    // for(int i=0;i<(int)make_control_points.size();i++)
    //     control_points.push_back(make_control_points[i]);
};

bool bSpline::getBSplinePoints(std::vector<glm::vec3> & bspline_points, int spline_resolution){
    bspline_points.clear();
    for(int segment_num=0;segment_num<num_cp-3;segment_num++){
        float t;
        glm::mat4x3 points = glm::mat4x3(
            control_points[segment_num],
            control_points[segment_num+1],
            control_points[segment_num+2],
            control_points[segment_num+3]
        );

        
        // std::cout << glm::to_string(points) << std::endl;


        
        // bspline_points.push_back(0.01f * points[0]);
        // bspline_points.push_back(0.01f * points[1]);
        // bspline_points.push_back(0.01f * points[2]);
        // bspline_points.push_back(0.01f * points[3]);
        
        // bspline_points.push_back(glm::vec3(0.0f,0.0f,0.0f));

        for(int i_t=0; i_t<spline_resolution; i_t++){
            t = (float) i_t / spline_resolution;

            glm::vec4 t_vec = glm::vec4(glm::pow(t, 3), glm::pow(t, 2), glm::pow(t, 1), glm::pow(t, 0));

            // std::cout << glm::to_string(points) << std::endl;
            // std::cout << glm::to_string(spline_mat) << std::endl;
            // std::cout << glm::to_string(t_vec) << std::endl;
            // std::cout << glm::to_string(spline_mat * points) << std::endl;

            //* t_vec * spline_mat

            glm::vec4 temp = 1/6.0f * glm::vec4(
                t_vec[0] * spline_mat[0][0] + t_vec[1] * spline_mat[1][0] + t_vec[2] * spline_mat[2][0] + t_vec[3] * spline_mat[3][0],
                t_vec[0] * spline_mat[0][1] + t_vec[1] * spline_mat[1][1] + t_vec[2] * spline_mat[2][1] + t_vec[3] * spline_mat[3][1],
                t_vec[0] * spline_mat[0][2] + t_vec[1] * spline_mat[1][2] + t_vec[2] * spline_mat[2][2] + t_vec[3] * spline_mat[3][2],
                t_vec[0] * spline_mat[0][3] + t_vec[1] * spline_mat[1][3] + t_vec[2] * spline_mat[2][3] + t_vec[3] * spline_mat[3][3]
            );

            glm::vec3 new_point = scale * glm::vec3(
                temp[0] * points[0][0] + temp[1] * points[1][0] + temp[2] * points[2][0] + temp[3] * points[3][0],
                temp[0] * points[0][1] + temp[1] * points[1][1] + temp[2] * points[2][1] + temp[3] * points[3][1],
                temp[0] * points[0][2] + temp[1] * points[1][2] + temp[2] * points[2][2] + temp[3] * points[3][2]
            );
            // if((t==0 && segment_num==0) || (t==spline_resolution-1 && segment_num==num_cp-4))
            //     bspline_points.push_back(new_point);

            // std::cout << glm::to_string(temp) << std::endl;

            // std::cout << glm::to_string(new_point) << std::endl;
            bspline_points.push_back(new_point);
        }
    }
    return true;
};

bool bSpline::getLocationsTangents(std::vector<glm::vec3> & locations, std::vector<glm::vec3> & tangents, std::vector<glm::vec3> & draw_tangents, int num_steps, float tan_scale, std::vector<glm::vec3> & os, std::vector<float> & fi, std::vector<glm::vec3> & normals, std::vector<glm::vec3> & binormals, std::vector<glm::mat3> & DCMs){
    locations.clear();
    tangents.clear();
    for(int segment_num=0;segment_num<num_cp-3;segment_num++){
        float t;
        glm::mat4x3 points = glm::mat4x3(
            control_points[segment_num],
            control_points[segment_num+1],
            control_points[segment_num+2],
            control_points[segment_num+3]
        );

        for(int i_t=0; i_t<num_steps; i_t++){
            t = (float) i_t / num_steps;

            glm::vec4 t_vec = glm::vec4(glm::pow(t, 3), glm::pow(t, 2), glm::pow(t, 1), glm::pow(t, 0));

            glm::vec4 temp = 1/6.0f * glm::vec4(
                t_vec[0] * spline_mat[0][0] + t_vec[1] * spline_mat[1][0] + t_vec[2] * spline_mat[2][0] + t_vec[3] * spline_mat[3][0],
                t_vec[0] * spline_mat[0][1] + t_vec[1] * spline_mat[1][1] + t_vec[2] * spline_mat[2][1] + t_vec[3] * spline_mat[3][1],
                t_vec[0] * spline_mat[0][2] + t_vec[1] * spline_mat[1][2] + t_vec[2] * spline_mat[2][2] + t_vec[3] * spline_mat[3][2],
                t_vec[0] * spline_mat[0][3] + t_vec[1] * spline_mat[1][3] + t_vec[2] * spline_mat[2][3] + t_vec[3] * spline_mat[3][3]
            );

            glm::vec3 new_point = scale * glm::vec3(
                temp[0] * points[0][0] + temp[1] * points[1][0] + temp[2] * points[2][0] + temp[3] * points[3][0],
                temp[0] * points[0][1] + temp[1] * points[1][1] + temp[2] * points[2][1] + temp[3] * points[3][1],
                temp[0] * points[0][2] + temp[1] * points[1][2] + temp[2] * points[2][2] + temp[3] * points[3][2]
            );

            locations.push_back(new_point);

            t_vec = glm::vec4(3.0f * glm::pow(t, 2), 2.0f * glm::pow(t, 1), 1.0f, 0.0f);

            temp = 1/6.0f * glm::vec4(
                t_vec[0] * spline_mat[0][0] + t_vec[1] * spline_mat[1][0] + t_vec[2] * spline_mat[2][0] + t_vec[3] * spline_mat[3][0],
                t_vec[0] * spline_mat[0][1] + t_vec[1] * spline_mat[1][1] + t_vec[2] * spline_mat[2][1] + t_vec[3] * spline_mat[3][1],
                t_vec[0] * spline_mat[0][2] + t_vec[1] * spline_mat[1][2] + t_vec[2] * spline_mat[2][2] + t_vec[3] * spline_mat[3][2],
                t_vec[0] * spline_mat[0][3] + t_vec[1] * spline_mat[1][3] + t_vec[2] * spline_mat[2][3] + t_vec[3] * spline_mat[3][3]
            );

            glm::vec3 new_tangent = scale * glm::vec3(
                temp[0] * points[0][0] + temp[1] * points[1][0] + temp[2] * points[2][0] + temp[3] * points[3][0],
                temp[0] * points[0][1] + temp[1] * points[1][1] + temp[2] * points[2][1] + temp[3] * points[3][1],
                temp[0] * points[0][2] + temp[1] * points[1][2] + temp[2] * points[2][2] + temp[3] * points[3][2]
            );

            // vec3 t_new = vec3(glm::pow(t, 2), glm::pow(t, 1), glm::pow(t, 0));

            // temp = 1/2.0f * glm::vec4(
            //     t_new[0] * -1.0f + t_new[1] * 2.0f + t_new[2] * -1.0f,
            //     t_new[0] * 3.0f + t_new[1] * -4.0f + t_new[2] * 0.f,
            //     t_new[0] * -3.0f + t_new[1] * 2.0f + t_new[2] * 1.0f,
            //     t_new[0] * 1.0f + t_new[1] * 0.0f + t_new[2] * 0.0f
            // );

            // glm::vec3 new_tangent = scale * glm::vec3(
            //     temp[0] * points[0][0] + temp[1] * points[1][0] + temp[2] * points[2][0] + temp[3] * points[3][0],
            //     temp[0] * points[0][1] + temp[1] * points[1][1] + temp[2] * points[2][1] + temp[3] * points[3][1],
            //     temp[0] * points[0][2] + temp[1] * points[1][2] + temp[2] * points[2][2] + temp[3] * points[3][2]
            // );

            tangents.push_back(normalize(new_tangent));

            t_vec = glm::vec4(6.0f * glm::pow(t, 1), 2.0f, 0.0f, 0.0f);

            temp = 1/6.0f * glm::vec4(
                t_vec[0] * spline_mat[0][0] + t_vec[1] * spline_mat[1][0] + t_vec[2] * spline_mat[2][0] + t_vec[3] * spline_mat[3][0],
                t_vec[0] * spline_mat[0][1] + t_vec[1] * spline_mat[1][1] + t_vec[2] * spline_mat[2][1] + t_vec[3] * spline_mat[3][1],
                t_vec[0] * spline_mat[0][2] + t_vec[1] * spline_mat[1][2] + t_vec[2] * spline_mat[2][2] + t_vec[3] * spline_mat[3][2],
                t_vec[0] * spline_mat[0][3] + t_vec[1] * spline_mat[1][3] + t_vec[2] * spline_mat[2][3] + t_vec[3] * spline_mat[3][3]
            );

            glm::vec3 new_normal_temp = scale * glm::vec3(
                temp[0] * points[0][0] + temp[1] * points[1][0] + temp[2] * points[2][0] + temp[3] * points[3][0],
                temp[0] * points[0][1] + temp[1] * points[1][1] + temp[2] * points[2][1] + temp[3] * points[3][1],
                temp[0] * points[0][2] + temp[1] * points[1][2] + temp[2] * points[2][2] + temp[3] * points[3][2]
            );

            glm::vec3 new_normal = cross(normalize(new_tangent),normalize(new_normal_temp));

            normals.push_back(new_normal);

            glm::vec3 new_binormal = cross(normalize(new_tangent), new_normal);

            binormals.push_back(new_binormal);

            glm::mat3 DCM = glm::mat3(
                normalize(new_tangent)[0], new_normal[0], new_binormal[0],
                normalize(new_tangent)[1], new_normal[1], new_binormal[1],
                normalize(new_tangent)[2], new_normal[2], new_binormal[2]
            );

            DCMs.push_back(DCM);

            // glm::mat3 R1 = glm::inverse(DCM);

            if(i_t%(num_steps/5)==0){
                draw_tangents.push_back(new_point);
                draw_tangents.push_back(new_point+normalize(new_tangent)*tan_scale);
            }

            
            vec3 s = vec3(0,0,1);
            vec3 e = normalize(new_tangent);
            vec3 osi = normalize(cross(s,e));
            //  normalize(vec3(
            //     s[1] * e[2] - e[1] * s[2],
            //     -(s[0] * e[2] - e[0] * s[2]),
            //     s[0] * e[1] - s[1] * e[2]
            // ));

            float fii = acos(dot(s,e)/(length(s)*length(e)));

            fi.push_back(fii);

            os.push_back(osi);


            // if(i_t%(num_steps/5)==0){
            //     draw_tangents.push_back(new_point);
            //     draw_tangents.push_back(new_point+osi*tan_scale);
            // }

        }
    }
    return true;
};