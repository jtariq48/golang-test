package api

import (
	"fmt"
	"log"

	"golang-test/api/handler"
	"golang-test/api/route"
	"golang-test/config"
	"golang-test/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func StartServer() {
	// Load configuration
	cfg := config.AppConfig

	dbURL := fmt.Sprintf("postgresql://%s:%s@%s:%s/%s", cfg.DBUser, cfg.DBPassword, cfg.DBHost, cfg.DBPort, cfg.DBName)

	db, err := gorm.Open(postgres.Open(dbURL), &gorm.Config{})
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
	}

	// Run database migrations
	if err := models.Migrate(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Initialize handlers
	userHandler := &handler.UserHandler{DB: db}

	// Set up routes
	r := route.SetupRouter(userHandler)

	// Start the server
	log.Println("Starting server on port 8085...")
	if err := r.Run(":8085"); err != nil {
		log.Fatalf("Error starting server: %v", err)
	}
}
