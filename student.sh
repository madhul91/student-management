#!/bin/bash

DATA_FILE="students.db"
LOG_FILE="logs.txt"
BACKUP_FILE="students_backup.db"

# Auto create data file if not exists
touch "$DATA_FILE"

# ========== COLORS ==========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ========== LOG FUNCTION ==========
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ========== SHOW MENU ==========
show_menu() {
    echo -e "${YELLOW}"
    echo "=============================="
    echo " Student Management System"
    echo "=============================="
    echo -e "${NC}"
    echo "1. Add Student"
    echo "2. Search Student"
    echo "3. View All Students"
    echo "4. Remove Student"
    echo "5. Exit"
    echo "Enter your choice:"
}

# ========== VALIDATE NUMBER ==========
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# ========== ADD STUDENT ==========
add_student() {

    read -p "Enter Roll Number: " roll

    if ! is_number "$roll"; then
        echo -e "${RED}Roll must be numeric!${NC}"
        return
    fi

    if grep -q "^$roll|" "$DATA_FILE"; then
        echo -e "${RED}Roll Number already exists!${NC}"
        return
    fi

    read -p "Enter Name: " name

    if [ -z "$name" ]; then
        echo -e "${RED}Name cannot be empty!${NC}"
        return
    fi

    read -p "Enter Age: " age

    if ! is_number "$age"; then
        echo -e "${RED}Age must be numeric!${NC}"
        return
    fi

    read -p "Enter Class: " class

    if [ -z "$class" ]; then
        echo -e "${RED}Class cannot be empty!${NC}"
        return
    fi

    echo "$roll|$name|$age|$class" >> "$DATA_FILE"

    echo -e "${GREEN}Student added successfully!${NC}"
    log_action "Added student Roll: $roll"
}

# ========== SEARCH STUDENT ==========
search_student() {

    echo "Search By:"
    echo "1. Roll Number"
    echo "2. Name"
    echo "3. Class"
    read -p "Enter option: " option

    case $option in
        1)
            read -p "Enter Roll Number: " roll
            result=$(grep "^$roll|" "$DATA_FILE")
            ;;
        2)
            read -p "Enter Name: " name
            result=$(grep -i "|$name|" "$DATA_FILE")
            ;;
        3)
            read -p "Enter Class: " class
            result=$(grep -i "|$class$" "$DATA_FILE")
            ;;
        *)
            echo -e "${RED}Invalid search option${NC}"
            return
            ;;
    esac

    if [ -z "$result" ]; then
        echo -e "${RED}Record not found${NC}"
    else
        echo -e "${GREEN}Record Found:${NC}"
        echo "----------------------------"
        echo "$result" | while IFS='|' read r n a c
        do
            echo "Roll  : $r"
            echo "Name  : $n"
            echo "Age   : $a"
            echo "Class : $c"
            echo "----------------------------"
        done
    fi
}

# ========== VIEW ALL ==========
view_students() {

    if [ ! -s "$DATA_FILE" ]; then
        echo -e "${RED}No records found.${NC}"
        return
    fi

    echo -e "${GREEN}All Students:${NC}"
    echo "----------------------------"

    while IFS='|' read r n a c
    do
        echo "Roll  : $r"
        echo "Name  : $n"
        echo "Age   : $a"
        echo "Class : $c"
        echo "----------------------------"
    done < "$DATA_FILE"
}

# ========== REMOVE STUDENT ==========
remove_student() {

    read -p "Enter Roll Number to delete: " roll

    if ! grep -q "^$roll|" "$DATA_FILE"; then
        echo -e "${RED}Roll Number not found!${NC}"
        return
    fi

    read -p "Are you sure you want to delete? (y/n): " confirm

    if [ "$confirm" != "y" ]; then
        echo -e "${YELLOW}Deletion cancelled.${NC}"
        return
    fi

    cp "$DATA_FILE" "$BACKUP_FILE"

    grep -v "^$roll|" "$DATA_FILE" > temp.db
    mv temp.db "$DATA_FILE"

    echo -e "${GREEN}Student removed successfully!${NC}"
    echo -e "${YELLOW}Backup saved as $BACKUP_FILE${NC}"

    log_action "Deleted student Roll: $roll"
}

# ========== EXIT ==========
exit_program() {
    echo -e "${GREEN}Exiting program...${NC}"
    exit 0
}

# ========== MAIN LOOP ==========
while true
do
    show_menu
    read choice

    case $choice in
        1) add_student ;;
        2) search_student ;;
        3) view_students ;;
        4) remove_student ;;
        5) exit_program ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
done