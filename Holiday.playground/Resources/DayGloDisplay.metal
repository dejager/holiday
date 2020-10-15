#include <metal_stdlib>
using namespace metal;

int mod(float time) {
  return int(fmod(time / 3.0, 4.0));
}

#define hash(p) fract(sin(dot(p, float3(127.1, 311.7, 74.7))) * 43758.5453123)

float2x2 rotate(float a) {
  return float2x2(cos(a), - sin(a),
                  sin(a), cos(a));
}

float noise(float3 p, float time) {
  float3 i = floor(p);
  float3 f = fract(p);
  f = f * f * (3.0 -2.0 * f);

  float v= mix( mix( mix(hash(i + float3(0,0,0)), hash(i + float3(1,0,0)), f.x),
                     mix(hash(i + float3(0,1,0)), hash(i + float3(1,1,0)), f.x), f.y),
                mix( mix(hash(i + float3(0,0,1)), hash(i + float3(1,0,1)), f.x),
                     mix(hash(i + float3(0,1,1)), hash(i + float3(1,1,1)), f.x), f.y), f.z);

  return mod(time) == 0 ? v : mod(time) == 1 ? 2.0 * v - 1.0 : mod(time) == 2 ? abs(2.0 * v - 1.0) : 1.0 - abs(2.0 * v - 1.0);
}

float fbm (float3 p, float time) {
  float v = 0.0;
  float a = 0.5;
  float2x2 r = rotate(0.37 + time / 1e4);

  for (int i = 0; i < 9; i++, p *= 2.0, a /= 2.0) {
    p.xy = p.xy * r,
    p.yz = p.yz * r,
    v += a * noise(p, time);
  }
  return v;
}

kernel void aVegetarianSinceTheInvasion(texture2d<float, access::write> o[[texture(0)]],
                                        constant float &time [[buffer(0)]],
                                        constant float2 *touchEvent [[buffer(1)]],
                                        constant int &numberOfTouches [[buffer(2)]],
                                        ushort2 gid [[thread_position_in_grid]]) {

  int width = o.get_width();
  int height = o.get_height();
  float2 res = float2(width, height);
  float2 p = float2(gid.xy);
  p /= res.y;

  float4 color = 0.5+ 0.55 * cos( 9.0 * fbm(float3(p, time / 3.0), time)+ float4(0, 23, 21, 0));
  o.write(color, gid);
}
