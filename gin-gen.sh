#!/bin/bash

PROJECT_NAME=$1;

usage() {
  echo "Usage: $0 <project name>"
  exit 1
}

initialize_git() {

git init "$PROJECT_NAME"

cd "$PROJECT_NAME"

}

generate_gitignore() {

cat <<EOT >> .gitignore

# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# Dependency directories (remove the comment below to include it)
vendor/
tmp/

EOT

}

generate_directories() {

mkdir -p app storage user utils config

}

generate_boilerplate() {

echo "Creating Boilerplate..."

generate_directories

cat <<EOT >> ./config/config.go

package config

const Port = 3000

EOT

cat <<EOT >> ./storage/gorm.go

package storage

import (
	"fmt"
	"$PROJECT_NAME/utils"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type Database struct {
	*gorm.DB
}

var DB *gorm.DB

func InitDB(conn string) error {
	db, err := gorm.Open(sqlite.Open(conn), &gorm.Config{})
	if err != nil {
		utils.Logger.Fatal("db initialization error:", err)
		return err
	}

	utils.Logger.Info("Database connected succesfully.")

	DB = db
	return nil
}

func GetDBConn() *gorm.DB {
	return DB
}

func GetTestDB() *gorm.DB {
	db, err := gorm.Open(sqlite.Open("gorm_test.db"), &gorm.Config{})
	if err != nil {
		fmt.Println("db initialization error:", err)
	}

	return db
}

func CloseTestDB(test_db *gorm.DB) {
	sqldb, _ := test_db.DB()
	sqldb.Close()
}

EOT


cat <<EOT >> ./storage/gorm_test.go

package storage_test

import (
	"$PROJECT_NAME/storage"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestDBConnBeforeInit(t *testing.T) {
	conn := storage.GetDBConn()

	assert.Nil(t, conn)
}

func TestDBConnAfterInit(t *testing.T) {
	err := storage.InitDB("gorm.db")

	assert.NoError(t, err)

	conn := storage.GetDBConn()

	assert.NotNil(t, conn)
}

EOT

cat <<EOT >> ./user/routes.go
package user

import "github.com/gin-gonic/gin"

func HelloHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"message": "Hello World",
	})
}

func UserRoutes(router *gin.RouterGroup) {
	userG := router.Group("/user")

	userG.GET("/", HelloHandler)
}

EOT

cat <<EOT >> ./utils/logger.go
package utils

import (
	"fmt"
	"log"
)

// Colors
const (
	reset   = "\033[0m"
	red     = "\033[31m"
	yellow  = "\033[33m"
	blue    = "\033[34m"
	magenta = "\033[35m"
	cyan    = "\033[36m"
	redBold = "\033[31;1m"
	//Green       = "\033[32m"
	//White       = "\033[37m"
	//BlueBold    = "\033[34;1m"
	//MagentaBold = "\033[35;1m"
	//YellowBold  = "\033[33;1m"
)

// Levels
const (
	LogDebug = iota + 1
	LogInfo
	LogWarning
	LogError
	LogFatal
	LogTrace
)

type LoggerConfig struct {
	ColorLabel bool
	ColorText  bool
	LogLevel   LogLevel
}

type LogLevel int

type LogInterface interface {
	//LogMode(level LogLevel) LogInterface
	WriteLog(string, string, string)
	Debug(string, ...interface{})
	Info(string, ...interface{})
	Warning(string, ...interface{})
	Error(string, ...interface{})
	Fatal(string, ...interface{})
	Trace(string, ...interface{})
}

type goLogger struct {
	LoggerConfig
}

func InitLogger(config LoggerConfig) LogInterface {
	return &goLogger{
		LoggerConfig: config,
	}
}

func (l *goLogger) WriteLog(color string, label string, logString string) {
	if l.ColorLabel {
		label = color + label + reset
	}
	if l.ColorText {
		logString = color + logString + reset
	}

	log.Printf(label + logString)
}

func (l *goLogger) Debug(logString string, args ...interface{}) {
	if l.LogLevel > LogDebug {
		return
	}
	label := "[ debug ] "
	color := magenta

	logString = fmt.Sprintf(logString, args...)

	l.WriteLog(color, label, logString)

}

func (l *goLogger) Info(logString string, args ...interface{}) {
	if l.LogLevel > LogInfo {
		return
	}
	label := "[ info ] "
	color := blue
	logString = fmt.Sprintf(logString, args...)

	l.WriteLog(color, label, logString)

}

func (l *goLogger) Warning(logString string, args ...interface{}) {
	if l.LogLevel > LogWarning {
		return
	}
	label := "[ warning ] "
	color := yellow
	logString = fmt.Sprintf(logString, args...)

	l.WriteLog(color, label, logString)

}

func (l *goLogger) Error(logString string, args ...interface{}) {
	if l.LogLevel > LogError {
		return
	}
	label := "[ error ] "
	color := red
	logString = fmt.Sprintf(logString, args...)

	l.WriteLog(color, label, logString)

}

func (l *goLogger) Fatal(logString string, args ...interface{}) {
	if l.LogLevel > LogFatal {
		return
	}
	label := "[ fatal ] "
	color := redBold
	logString = fmt.Sprintf(logString, args...)

	l.WriteLog(color, label, logString)

}

func (l *goLogger) Trace(logString string, args ...interface{}) {
	if l.LogLevel > LogTrace {
		return
	}
	label := "[ trace ] "
	color := cyan
	logString = fmt.Sprintf(logString, args...)

	l.WriteLog(color, label, logString)

}

var Logger = InitLogger(LoggerConfig{})

EOT

cat <<EOT >> ./app/init.go
package app

import (
	"$PROJECT_NAME/storage"
	"$PROJECT_NAME/user"

	"github.com/gin-gonic/gin"
)

func InitializeDB() {
	storage.InitDB("gorm.db")
}

func InitializeRoute() *gin.Engine {
	r := gin.Default()
	apiG := r.Group("/api")

	user.UserRoutes(apiG)

	return r
}

EOT

cat <<EOT >> main.go
package main

import (
	"fmt"
	"$PROJECT_NAME/app"
	"$PROJECT_NAME/config"
)

func main() {
	app.InitializeDB()

	r := app.InitializeRoute()

	port := fmt.Sprintf(":%d", config.Port)
	r.Run(port)
}

EOT

cat <<EOT >> Dockerfile.dev
FROM golang:buster

RUN curl -fLo install.sh https://raw.githubusercontent.com/cosmtrek/air/master/install.sh \\
    && chmod +x install.sh && sh install.sh && cp ./bin/air /bin/air

WORKDIR /gym-manager

COPY go.mod .
RUN go mod download

COPY . .

EXPOSE 3000

CMD ["air"]

EOT


}


initialize_git

generate_gitignore

generate_boilerplate


go mod init $PROJECT_NAME
go mod tidy
go mod vendor

echo "Successfully Generated Gin Boilerplate, cd $PROJECT_NAME then, go run main.go to continue..."