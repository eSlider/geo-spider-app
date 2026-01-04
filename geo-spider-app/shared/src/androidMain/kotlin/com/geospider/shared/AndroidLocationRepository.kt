package com.geospider.shared

import android.content.Context
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import com.geospider.shared.database.GeoSpiderDatabase

/**
 * Extension function to convert database row to LocationData
 */
private fun com.geospider.shared.database.Location_data.toLocationData(): LocationData {
    return LocationData(
        latitude = latitude,
        longitude = longitude,
        accuracy = accuracy.toFloat(),
        altitude = altitude,
        speed = speed.toFloat(),
        bearing = bearing.toFloat(),
        timestamp = timestamp,
        provider = provider
    )
}

/**
 * Android implementation of LocationRepository using SQLDelight
 */
class AndroidLocationRepository(
    context: Context
) : LocationRepository {
    
    private val database: GeoSpiderDatabase
    
    init {
        val driver: SqlDriver = AndroidSqliteDriver(
            schema = GeoSpiderDatabase.Schema,
            context = context,
            name = "geospider.db"
        )
        database = GeoSpiderDatabase(driver)
    }
    
    override suspend fun insertLocation(location: LocationData): Long {
        database.geoSpiderDatabaseQueries.insertLocation(
            latitude = location.latitude,
            longitude = location.longitude,
            accuracy = location.accuracy.toDouble(),
            altitude = location.altitude,
            speed = location.speed.toDouble(),
            bearing = location.bearing.toDouble(),
            timestamp = location.timestamp,
            provider = location.provider
        )
        // Get the last inserted row ID
        return database.geoSpiderDatabaseQueries.lastInsertRowId().executeAsOne()
    }
    
    override suspend fun getAllLocations(): List<LocationData> {
        return database.geoSpiderDatabaseQueries.getAllLocations()
            .executeAsList()
            .map { it.toLocationData() }
    }
    
    override suspend fun getUnsyncedLocations(): List<LocationData> {
        return database.geoSpiderDatabaseQueries.getUnsyncedLocations()
            .executeAsList()
            .map { it.toLocationData() }
    }
    
    override suspend fun getUnsyncedLocationIds(): List<Long> {
        return database.geoSpiderDatabaseQueries.getUnsyncedLocationIds()
            .executeAsList()
    }
    
    override suspend fun getLocationCount(): Long {
        return database.geoSpiderDatabaseQueries.getLocationCount()
            .executeAsOne()
    }
    
    override suspend fun getUnsyncedCount(): Long {
        return database.geoSpiderDatabaseQueries.getUnsyncedCount()
            .executeAsOne()
    }
    
    override suspend fun markAsSynced(id: Long) {
        database.geoSpiderDatabaseQueries.markAsSynced(id)
    }
    
    override suspend fun markBatchAsSynced(ids: List<Long>) {
        database.transaction {
            ids.forEach { id ->
                database.geoSpiderDatabaseQueries.markAsSynced(id)
            }
        }
    }
    
    override suspend fun deleteLocation(id: Long) {
        database.geoSpiderDatabaseQueries.deleteLocation(id)
    }
    
    override suspend fun deleteSyncedLocations() {
        database.geoSpiderDatabaseQueries.deleteSyncedLocations()
    }
    
    override suspend fun clearAllLocations() {
        database.geoSpiderDatabaseQueries.clearAllLocations()
    }
    
    override suspend fun toGeoJsonFeatureCollection(): GeoJsonFeatureCollection {
        val locations = getAllLocations()
        val features = locations.map { it.toGeoJsonFeature() }
        return GeoJsonFeatureCollection(features = features)
    }
    
    override suspend fun getUnsyncedGeoJsonFeatureCollection(): GeoJsonFeatureCollection {
        val locations = getUnsyncedLocations()
        val features = locations.map { it.toGeoJsonFeature() }
        return GeoJsonFeatureCollection(features = features)
    }
}

