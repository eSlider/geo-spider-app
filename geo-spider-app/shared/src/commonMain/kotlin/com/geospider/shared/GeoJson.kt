package com.geospider.shared

import kotlinx.serialization.Serializable

/**
 * GeoJSON Point geometry
 */
@Serializable
data class GeoJsonPoint(
    val type: String = "Point",
    val coordinates: List<Double> // [longitude, latitude, altitude?]
) {
    init {
        require(coordinates.size >= 2) { "Coordinates must have at least longitude and latitude" }
        require(coordinates[1] in -90.0..90.0) { "Latitude must be between -90 and 90" }
        require(coordinates[0] in -180.0..180.0) { "Longitude must be between -180 and 180" }
    }
}

/**
 * GeoJSON Feature with properties
 */
@Serializable
data class GeoJsonFeature(
    val type: String = "Feature",
    val geometry: GeoJsonPoint,
    val properties: Map<String, String>
)

/**
 * GeoJSON FeatureCollection
 */
@Serializable
data class GeoJsonFeatureCollection(
    val type: String = "FeatureCollection",
    val features: List<GeoJsonFeature>
)

