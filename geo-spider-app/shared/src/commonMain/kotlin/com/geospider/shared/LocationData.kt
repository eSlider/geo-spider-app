package com.geospider.shared

import kotlinx.serialization.Serializable

@Serializable
data class LocationData(
    val latitude: Double,
    val longitude: Double,
    val accuracy: Float = 0f,
    val altitude: Double = 0.0,
    val speed: Float = 0f,
    val bearing: Float = 0f,
    val timestamp: Long = System.currentTimeMillis(),
    val provider: String = "GPS"
) {
    init {
        require(latitude in -90.0..90.0) { "Latitude must be between -90 and 90" }
        require(longitude in -180.0..180.0) { "Longitude must be between -180 and 180" }
        require(provider.isNotBlank()) { "Provider cannot be blank" }
        require(accuracy >= 0) { "Accuracy must be non-negative" }
    }
    
    /**
     * Converts LocationData to GeoJSON Point
     */
    fun toGeoJsonPoint(): GeoJsonPoint {
        val coordinates = mutableListOf(longitude, latitude)
        if (altitude != 0.0) {
            coordinates.add(altitude)
        }
        return GeoJsonPoint(coordinates = coordinates)
    }
    
    /**
     * Converts LocationData to GeoJSON Feature
     */
    fun toGeoJsonFeature(): GeoJsonFeature {
        return GeoJsonFeature(
            geometry = toGeoJsonPoint(),
            properties = mapOf(
                "accuracy" to accuracy.toString(),
                "speed" to speed.toString(),
                "bearing" to bearing.toString(),
                "timestamp" to timestamp.toString(),
                "provider" to provider
            )
        )
    }
}
