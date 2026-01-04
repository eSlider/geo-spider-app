package com.geospider.shared

/**
 * Repository interface for location data storage operations
 */
interface LocationRepository {
    suspend fun insertLocation(location: LocationData): Long
    suspend fun getAllLocations(): List<LocationData>
    suspend fun getUnsyncedLocations(): List<LocationData>
    suspend fun getUnsyncedLocationIds(): List<Long>
    suspend fun getLocationCount(): Long
    suspend fun getUnsyncedCount(): Long
    suspend fun markAsSynced(id: Long)
    suspend fun markBatchAsSynced(ids: List<Long>)
    suspend fun deleteLocation(id: Long)
    suspend fun deleteSyncedLocations()
    suspend fun clearAllLocations()
    suspend fun toGeoJsonFeatureCollection(): GeoJsonFeatureCollection
    suspend fun getUnsyncedGeoJsonFeatureCollection(): GeoJsonFeatureCollection
}

