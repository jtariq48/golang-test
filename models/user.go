package models

import "gorm.io/gorm"

// User defines the structure of the user model
type User struct {
	ID   uint   `json:"id"`
	Name string `json:"name"`
}

// Migrate function will apply the migration
func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(&User{})
}
