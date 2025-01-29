#ifndef BSPLINE_HPP
#define BSPLINE_HPP

class bSpline{
    public:
    float scale = 0.08f;
    std::vector<glm::vec3> control_points;
    int num_cp;
    GLfloat spline_mat_scale = 1/6.0f;
    glm::mat4 spline_mat = glm::mat4(
        -1.0f,   3.0f,    -3.0f,   1.0f,
        3.0f,    -6.0f,   3.0f,    0.0f,
        -3.0f,   0.0f,    3.0f,    0.0f,
        1.0f,    4.0f,    1.0f,    0.0f
    );
    bSpline(float make_control_points[], int make_num_cp);
    bool getBSplinePoints(std::vector<glm::vec3> & bspline_points, int spline_resolution);
    bool getLocationsTangents(std::vector<glm::vec3> & locations, std::vector<glm::vec3> & tangents, std::vector<glm::vec3> & draw_tangents, int num_steps, float tan_scale, std::vector<glm::vec3> & os, std::vector<float> & fi, std::vector<glm::vec3> & normals, std::vector<glm::vec3> & binormals, std::vector<glm::mat3> & DCMs);
};

#endif
