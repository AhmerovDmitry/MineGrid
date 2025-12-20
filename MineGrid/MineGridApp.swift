//
//  MineGridApp.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import SwiftUI
import SwiftData

/// Главная точка входа в приложение
@main
struct MineGridApp: App {
    private let logger: LogService
    
    init() {
        let appLogger = AppLogger(category: "App")
        appLogger.info("MineGridApp initializing")
        self.logger = appLogger
    }
    
    var sharedModelContainer: ModelContainer = {
        let logger = AppLogger(category: "App")
        logger.info("Creating ModelContainer")
        
        let schema = Schema([
            GameResult.self,
            SavedGame.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            logger.info("Schema created with \(schema.entities.count) entities")
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            logger.info("ModelContainer created successfully")
            return container
        } catch {
            logger.error("Failed to create ModelContainer", error: error)
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        logger.debug("Creating WindowGroup scene")
        return WindowGroup {
            MainMenuView()
                .onAppear {
                    logger.info("MainMenuView appeared")
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
