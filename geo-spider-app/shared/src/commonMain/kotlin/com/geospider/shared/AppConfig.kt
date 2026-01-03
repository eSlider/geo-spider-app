package com.geospider.shared

import kotlinx.serialization.Serializable

@Serializable
data class AppConfig(
    val serverUrl: String,
    val collectionIntervalSeconds: Int = 60,
    val syncBatchSize: Int = 50,
    val maxOfflineStorageDays: Int = 7
) {
    init {
        require(serverUrl.isNotBlank()) { "Server URL cannot be blank" }
        require(collectionIntervalSeconds > 0) { "Collection interval must be positive" }
        require(syncBatchSize > 0) { "Sync batch size must be positive" }
        require(maxOfflineStorageDays > 0) { "Max offline storage days must be positive" }
    }
    
    companion object {
        fun default(): AppConfig = AppConfig(
            serverUrl = "https://api.example.com/locations",
            collectionIntervalSeconds = 60,
            syncBatchSize = 50,
            maxOfflineStorageDays = 7
        )
    }
}
