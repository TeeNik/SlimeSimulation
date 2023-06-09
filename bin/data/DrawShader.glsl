#version 440

struct Trail
{
	vec4 value;
};

struct SpeciesInfo
{
	float moveSpeed;
	float turnSpeed;
	float senseDistance;
	float senseAngle;
	int sensorSize;
	vec4 color;
};

layout(std140, binding = 1) buffer trailMapBuffer { Trail trailMap[]; };
layout(rgba8, binding = 2) uniform writeonly image2D texture;
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

uniform int width;
uniform int height; 
uniform vec4 cellColor;

void main()
{
	int i, j;
	i = int(gl_GlobalInvocationID.x);
	j = int(gl_GlobalInvocationID.y);

	int idx = i + j * width;
	vec4 mask = vec4(1,0,0,0);
	vec4 color = cellColor * dot(trailMap[idx].value, mask);
    imageStore(texture, ivec2(i, j), color);
}