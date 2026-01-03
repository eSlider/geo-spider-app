package com.geospider.shared

import kotlinx.coroutines.flow.Flow

interface LocationProvider {
    suspend fun getCurrentLocation(): LocationData?
    fun isLocationServiceEnabled(): Boolean
    suspend fun requestPermissions(): Boolean
}

interface LocationService {
    suspend fun getCurrentLocation(): LocationData?
    fun isLocationServiceEnabled(): Boolean
    suspend fun requestPermissions(): Boolean
}

class LocationServiceImpl(
    private val locationProvider: LocationProvider
) : LocationService {
    override suspend fun getCurrentLocation(): LocationData? {
        return if (isLocationServiceEnabled()) {
            locationProvider.getCurrentLocation()
        } else {
            null
        }
    }
    
    override fun isLocationServiceEnabled(): Boolean {
        return locationProvider.isLocationServiceEnabled()
    }
    
    override suspend fun requestPermissions(): Boolean {
        return locationProvider.requestPermissions()
    }
}
