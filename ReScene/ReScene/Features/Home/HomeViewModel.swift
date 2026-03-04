//
//  HomeViewModel.swift
//  ReScene
//

import CoreLocation
import Observation
import PhotosUI
import SwiftUI

/// Drives the Home screen's state and orchestrates the photo selection workflow.
///
/// Responsibilities:
/// - Managing the `PhotosPicker` selection binding
/// - Loading image data and extracting EXIF GPS via `PhotoPickerServiceProtocol`
/// - Fetching the device location via `LocationServiceProtocol` as a fallback
/// - Handing off the prepared `PhotoData` to the coordinator for navigation
@Observable
final class HomeViewModel {

    // MARK: - Published State

    /// The current `PhotosPicker` selection, observed by the view.
    var pickerItem: PhotosPickerItem?

    /// The loaded photo data ready for processing, displayed as a preview.
    var selectedPhoto: PhotoData?

    /// Indicates an async operation is in progress.
    var isLoading = false

    /// The current error to display, if any.
    var error: AppError?

    /// Controls visibility of the error alert.
    var showError = false

    // MARK: - Dependencies

    private let locationService: any LocationServiceProtocol
    private let photoPickerService: any PhotoPickerServiceProtocol
    private let coordinator: AppCoordinator

    // MARK: - Init

    init(
        locationService: any LocationServiceProtocol,
        photoPickerService: any PhotoPickerServiceProtocol,
        coordinator: AppCoordinator
    ) {
        self.locationService = locationService
        self.photoPickerService = photoPickerService
        self.coordinator = coordinator
    }

    // MARK: - Actions

    /// Called when the user selects a photo from the picker.
    ///
    /// Loads the image data, extracts GPS metadata, and if no EXIF GPS is found,
    /// falls back to the device's current location.
    func handlePhotoSelection() async {
        guard let pickerItem else { return }

        isLoading = true
        error = nil

        do {
            let imageData = try await pickerItem.loadTransferable(type: Data.self)
            var photo = try await photoPickerService.loadPhoto(from: imageData)

            if photo.coordinate == nil {
                photo = await enrichWithDeviceLocation(photo)
            }

            selectedPhoto = photo
        } catch let appError as AppError {
            presentError(appError)
        } catch {
            presentError(.unknown(error.localizedDescription))
        }

        isLoading = false
    }

    /// Navigates to the processing screen with the currently selected photo.
    func proceedToProcessing() {
        guard let selectedPhoto else { return }
        coordinator.startProcessing(with: selectedPhoto)
        resetSelection()
    }

    /// Clears the current selection so the user can pick a different photo.
    func resetSelection() {
        pickerItem = nil
        selectedPhoto = nil
        error = nil
    }

    // MARK: - Private

    /// Attempts to enrich a `PhotoData` with the device's current GPS coordinate
    /// when the photo's EXIF data lacks location information.
    private func enrichWithDeviceLocation(_ photo: PhotoData) async -> PhotoData {
        do {
            let coordinate = try await locationService.fetchCurrentLocation()
            return PhotoData(
                id: photo.id,
                imageData: photo.imageData,
                coordinate: coordinate,
                locationName: photo.locationName
            )
        } catch {
            return photo
        }
    }

    private func presentError(_ appError: AppError) {
        error = appError
        showError = true
    }
}
