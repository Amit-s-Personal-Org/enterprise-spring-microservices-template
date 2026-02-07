#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-app.yml"

start_services() {
    echo -e "${YELLOW}Starting SEC Microservices Environment (Full Docker Mode)...${NC}"
    
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        echo -e "${RED}Error: $DOCKER_COMPOSE_FILE not found!${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Building and starting all services... this may take a few minutes on first run.${NC}"
    
    docker compose -f "$DOCKER_COMPOSE_FILE" up -d --build
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}All services started successfully!${NC}"
        echo -e "${GREEN}Web UI:         http://localhost:4200 (Run 'npm start' in angular-ui separately if not containerized)${NC}"
        echo -e "${GREEN}Keycloak:       http://localhost:8080${NC}"
        echo -e "${GREEN}BFF:            http://localhost:8081${NC}"
        echo -e "${GREEN}Gateway:        http://localhost:8888${NC}"
        echo -e "${GREEN}Zipkin:         http://localhost:9411${NC}"
        echo -e "${GREEN}Grafana:        http://localhost:3000${NC}"
        echo -e "\n${YELLOW}To view logs: docker compose -f $DOCKER_COMPOSE_FILE logs -f${NC}"
    else
        echo -e "\n${RED}Failed to start services.${NC}"
        exit 1
    fi
}

stop_services() {
    echo -e "${YELLOW}Stopping SEC Microservices Environment...${NC}"
    
    if [ -f "$DOCKER_COMPOSE_FILE" ]; then
        docker compose -f "$DOCKER_COMPOSE_FILE" down
        echo -e "${GREEN}All services stopped.${NC}"
    else
        echo -e "${RED}Error: $DOCKER_COMPOSE_FILE not found!${NC}"
    fi
    
    # Legacy Cleanup: Check for any orphaned local Java processes (safety net)
    echo -e "${YELLOW}Checking for any legacy local processes...${NC}"
    pids=$(lsof -Pi :8081,8888,8082,8083,8084 -sTCP:LISTEN -t)
    if [ -n "$pids" ]; then
        echo -e "${YELLOW}Killing orphaned local Java processes: $pids${NC}"
        kill $pids 2>/dev/null
    fi
}

test_services() {
    echo -e "${YELLOW}Running tests for all services (Maven Local)...${NC}"

    run_test() {
        SERVICE_DIR=$1
        NAME=$2
        echo -e "\n${YELLOW}[Testing $NAME]${NC}"
        (cd "$SERVICE_DIR" && mvn test)
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}$NAME tests passed.${NC}"
        else
            echo -e "${RED}$NAME tests failed.${NC}"
            exit 1
        fi
    }

    run_test "bff" "BFF Service"
    run_test "gateway" "Gateway Service"
    run_test "profile-service" "Profile Service"
    run_test "order-service" "Order Service"
    run_test "keycloak-admin-service" "Keycloak Admin Service"

    echo -e "\n${GREEN}All tests passed successfully!${NC}"
}

# Main Execution Logic
case "$1" in
    start|"")
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        stop_services
        sleep 2
        start_services
        ;;
    test)
        test_services
        ;;
    *)
        echo -e "${RED}Usage: $0 {start|stop|restart|test}${NC}"
        exit 1
        ;;
esac
