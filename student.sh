#!/bin/bash

DATA_FILE="students.db"
LOG_FILE="logs.txt"
BACKUP_FILE="students_backup.db"

touch "$DATA_FILE"

# COLORS
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# LOG FUNCTION
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# MENU
show_menu() {
    echo -e "${RED}==============================${NC}"
    echo -e "${YELLOW} Student Management System${NC}"
    echo -e "${RED}==============================${NC}"
    echo -e "${NC}"
    echo -e "${CYAN}1)${NC} Add Student"
    echo -e "${CYAN}2)${NC} Search Student"
    echo -e "${CYAN}3)${NC} View All Students"
    echo -e "${CYAN}4)${NC} Remove Student"
    echo -e "${CYAN}5)${NC} Update Student"
    echo -e "${CYAN}6)${NC} View logs"
    echo -e "${CYAN}7)${NC} Exit"

}

# NUMBER VALIDATION
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# ADD STUDENT
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

    if [[ ! "$name" =~ ^[A-Za-z\ ]+$ ]]; then
        echo -e "${RED}Name must contain only alphabets!${NC}"
        return
    fi

    read -p "Enter Age: " age

    if ! is_number "$age" || [ "$age" -le 0 ]; then
        echo -e "${RED}Age must be positive number!${NC}"
        return
    fi

    read -p "Enter Class (1-12): " class

    if ! is_number "$class" || [ "$class" -lt 1 ] || [ "$class" -gt 12 ]; then
        echo -e "${RED}Class must be between 1 and 12!${NC}"
        return
    fi

    if grep -iq "|$name|.*|$class$" "$DATA_FILE"; then
        echo -e "${RED}Student with same Name and Class already exists!${NC}"
        return
    fi

    echo "$roll|$name|$age|$class" >> "$DATA_FILE"

    echo -e "${GREEN}Student added successfully!${NC}"
    log_action "Added student Roll: $roll"
}

# SEARCH STUDENT
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

# VIEW ALL STUDENTS
view_students() {

    if [ ! -s "$DATA_FILE" ]; then
        echo -e "${RED}No records found.${NC}"
        return
    fi

    printf "\n%-10s %-20s %-10s %-10s\n" "ROLL" "NAME" "AGE" "CLASS"
    echo "-----------------------------------------------------"

    while IFS='|' read r n a c
    do
        printf "%-10s %-20s %-10s %-10s\n" "$r" "$n" "$a" "$c"
    done < "$DATA_FILE"
}

# REMOVE STUDENT
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

# UPDATE STUDENT
update_student() {

    read -p "Enter Roll Number to update: " roll

    if ! grep -q "^$roll|" "$DATA_FILE"; then
        echo -e "${RED}Student not found!${NC}"
        return
    fi

    read -p "Enter New Name: " name

    if [[ ! "$name" =~ ^[A-Za-z\ ]+$ ]]; then
        echo -e "${RED}Name must contain only alphabets!${NC}"
        return
    fi

    read -p "Enter New Age: " age

    if ! is_number "$age" || [ "$age" -le 0 ]; then
        echo -e "${RED}Invalid Age!${NC}"
        return
    fi

    read -p "Enter New Class (1-12): " class

    if ! is_number "$class" || [ "$class" -lt 1 ] || [ "$class" -gt 12 ]; then
        echo -e "${RED}Invalid Class!${NC}"
        return
    fi

    cp "$DATA_FILE" "$BACKUP_FILE"

    grep -v "^$roll|" "$DATA_FILE" > temp.db
    echo "$roll|$name|$age|$class" >> temp.db
    mv temp.db "$DATA_FILE"

    echo -e "${GREEN}Student updated successfully!${NC}"
    log_action "Updated student Roll: $roll"
}

# EXIT
exit_program() {
    echo -e "${GREEN}Exiting program...${NC}"
    exit 0
}

view_logs() {

awk '
/Added/ {print "\033[0;32m" $0 "\033[0m"; next}
/Deleted/ {print "\033[0;31m" $0 "\033[0m"; next}
/Updated/ {print "\033[0;34m" $0 "\033[0m"; next}
{print}
' "$LOG_FILE"

}

# MAIN LOOP
while true
do
    show_menu
    read choice

  case $choice in
    1) 
        echo -e "${YELLOW}Adding Student...${NC}"
        add_student 
        ;;
    2) 
        echo -e "${BLUE}Searching Student...${NC}"
        search_student 
        ;;
    3) 
        echo -e "${YELLOW}Displaying All Students...${NC}"
        view_students 
        ;;
    4) 
        echo -e "${RED}Removing Student...${NC}"
        remove_student 
        ;;
    5) 
        echo -e "${BLUE}Updating Student...${NC}"
        update_student 
        ;;
    6) 
         echo -e "${CYAN}Viewing Logs...${NC}"
        view_logs
        ;;
    7)
         echo -e "${GREEN}Exiting Program...${NC}"
        exit_program 
        ;;
    *) 
        echo -e "${RED}Invalid option! Please try again.${NC}" 
        ;;
  esac
    

done