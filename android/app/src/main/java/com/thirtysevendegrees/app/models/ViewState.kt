package com.thirtysevendegrees.app.models

sealed class ViewState<out T> {
    object Loading : ViewState<Nothing>()
    data class Success<T>(val data: T) : ViewState<T>()
    object Empty : ViewState<Nothing>()
    data class Error(val message: String) : ViewState<Nothing>()
    data class Refreshing<T>(val data: T) : ViewState<T>()
}
