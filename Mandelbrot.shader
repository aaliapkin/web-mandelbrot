#shader vertex
#version 400 core

layout(location = 0) in vec3 aPos;

out vec4 uv;

uniform mat4 u_MVP;

void main()
{
    gl_Position = vec4(aPos, 1.0);
    uv = inverse(u_MVP) * gl_Position;
};

#shader fragment
#version 400 core
#define MAX_ITERATIONS 255

out vec4 FragColor;
in vec4 uv;

uniform dvec4 u_bounds;

double map(double value, double min1, double max1, double min2, double max2) {
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void main()
{
    dvec2 c = dvec2(
        map(uv.x, -1.0, 1.0, u_bounds.x, u_bounds.y),
        map(uv.y, -1.0, 1.0, u_bounds.z, u_bounds.w)
    );

    dvec2 z;
    float iter;

    // additional iterations
    float thininness = length(vec2(u_bounds.y - u_bounds.x, u_bounds.w - u_bounds.z));
    float add = (1 - log(thininness)) * MAX_ITERATIONS / 3;
    //if(add > MAX_ITERATIONS * 3) add = MAX_ITERATIONS* 3;

    float max_it = MAX_ITERATIONS + add;

    for (iter = 0.0; iter < max_it; iter++) {
        z = dvec2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + c;
        if (length(z) > 2) break;
    }

    float t = (iter == max_it) ? 0 : (iter / max_it);
//    float t = add / MAX_ITERATIONS / 3;

    FragColor = vec4(
         9.0 *    (1 - t)    * pow(t, 3),
        15.0 * pow(1 - t, 2) * pow(t, 2),
         8.5 * pow(1 - t, 3) *     t,
        1.0);

//    FragColor = vec4(
//        t,
//        t,
//        t,
//        1.0);
};
