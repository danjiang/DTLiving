uniform sampler2D u_texture;

const lowp int GAUSSIAN_SAMPLES = 9;

varying highp vec2 v_blurCoordinates[GAUSSIAN_SAMPLES];

uniform mediump float u_distanceNormalizationFactor;

void main() {
    lowp vec4 centralColor;
    lowp float gaussianWeightTotal;
    lowp vec4 sum;
    lowp vec4 sampleColor;
    lowp float distanceFromCentralColor;
    lowp float gaussianWeight;
    
    centralColor = texture2D(u_texture, v_blurCoordinates[4]);
    gaussianWeightTotal = 0.18;
    sum = centralColor * 0.18;
    
    sampleColor = texture2D(u_texture, v_blurCoordinates[0]);
    distanceFromCentralColor = min(distance(centralColor, sampleColor) * u_distanceNormalizationFactor, 1.0);
    gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = texture2D(u_texture, v_blurCoordinates[1]);
    distanceFromCentralColor = min(distance(centralColor, sampleColor) * u_distanceNormalizationFactor, 1.0);
    gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = texture2D(u_texture, v_blurCoordinates[2]);
    distanceFromCentralColor = min(distance(centralColor, sampleColor) * u_distanceNormalizationFactor, 1.0);
    gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = texture2D(u_texture, v_blurCoordinates[3]);
    distanceFromCentralColor = min(distance(centralColor, sampleColor) * u_distanceNormalizationFactor, 1.0);
    gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = texture2D(u_texture, v_blurCoordinates[5]);
    distanceFromCentralColor = min(distance(centralColor, sampleColor) * u_distanceNormalizationFactor, 1.0);
    gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = texture2D(u_texture, v_blurCoordinates[6]);
    distanceFromCentralColor = min(distance(centralColor, sampleColor) * u_distanceNormalizationFactor, 1.0);
    gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = texture2D(u_texture, v_blurCoordinates[7]);
    distanceFromCentralColor = min(distance(centralColor, sampleColor) * u_distanceNormalizationFactor, 1.0);
    gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = texture2D(u_texture, v_blurCoordinates[8]);
    distanceFromCentralColor = min(distance(centralColor, sampleColor) * u_distanceNormalizationFactor, 1.0);
    gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;
    
    gl_FragColor = sum / gaussianWeightTotal;
}