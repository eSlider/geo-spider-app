package com.geospider.shared

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import androidx.core.content.ContextCompat

class AndroidLocationProvider(
    private val context: Context
) : LocationProvider {
    
    private val locationManager: LocationManager
        get() = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    
    override fun isLocationServiceEnabled(): Boolean {
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
               locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    }
    
    override suspend fun requestPermissions(): Boolean {
        val hasFineLocation = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        
        val hasCoarseLocation = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        
        return hasFineLocation || hasCoarseLocation
    }
    
    override suspend fun getCurrentLocation(): LocationData? {
        if (!requestPermissions()) {
            return null
        }
        
        if (!isLocationServiceEnabled()) {
            return null
        }
        
        return try {
            val location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                ?: locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
            
            location?.let {
                LocationData(
                    latitude = it.latitude,
                    longitude = it.longitude,
                    accuracy = it.accuracy,
                    altitude = it.altitude,
                    speed = it.speed,
                    bearing = it.bearing,
                    timestamp = it.time,
                    provider = it.provider ?: "GPS"
                )
            }
        } catch (e: SecurityException) {
            null
        }
    }
}
