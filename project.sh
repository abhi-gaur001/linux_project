ACCOUNTS="accounts.txt"

if [ ! -f $ACCOUNTS ]; then
    touch $ACCOUNTS
fi

create_account() {
    echo "Enter your Name:"
    read name
    echo "Enter Account Number:"
    read acc
    echo "Set Password:"
    read pass
    echo "Enter Initial Balance:"
    read bal

    echo "$acc:$pass:$name:$bal" >> $ACCOUNTS
    echo "Account Created Successfully!"
}

login() {
    echo "Enter Account Number:"
    read acc
    echo "Enter Password:"
    read pass

    # find matching account
    record=$(grep "^$acc:$pass" $ACCOUNTS)

    if [ -z "$record" ]; then
        echo "Invalid Login!"
        return
    fi

    echo "Login Successful! Welcome"
    user_menu "$acc" "$pass"
}

user_menu() {
    acc=$1
    pass=$2

    while true
    do
        echo ""
        echo "===== USER MENU ====="
        echo "1. Check Balance"
        echo "2. Transfer Money"
        echo "3. Logout"
        echo "Enter your choice:"
        read ch

        case $ch in
            1) check_balance "$acc" "$pass" ;;
            2) transfer "$acc" "$pass" ;;
            3) break ;;
            *) echo "Invalid Choice!" ;;
        esac
    done
}

check_balance() {
    acc=$1
    pass=$2

    bal=$(grep "^$acc:$pass" $ACCOUNTS | cut -d ":" -f4)
    echo "Your Current Balance: ₹$bal"
}

transfer() {
    sender=$1
    pass=$2

    echo "Enter Receiver Account Number:"
    read recv
    echo "Enter Amount to Transfer:"
    read amt

    sender_rec=$(grep "^$sender:$pass" $ACCOUNTS)
    sender_bal=$(echo $sender_rec | cut -d ":" -f4)

    recv_rec=$(grep "^$recv:" $ACCOUNTS)
    if [ -z "$recv_rec" ]; then
        echo "Receiver not found!"
        return
    fi

    recv_bal=$(echo $recv_rec | cut -d ":" -f4)

    if [ $sender_bal -lt $amt ]; then
        echo "Insufficient Balance!"
        return
    fi

    new_sender_bal=$((sender_bal - amt))
    new_recv_bal=$((recv_bal + amt))

    sed -i "s/^$sender:$pass:.*/$sender:$pass:$(echo $sender_rec | cut -d ':' -f3):$new_sender_bal/" $ACCOUNTS
    sed -i "s/^$recv:.*/$recv:$(echo $recv_rec | cut -d ':' -f2):$(echo $recv_rec | cut -d ':' -f3):$new_recv_bal/" $ACCOUNTS

    echo "Transfer Successful!"
}

while true
do
    echo ""
    echo "===== BANK SYSTEM ====="
    echo "1. Create Account"
    echo "2. Login"
    echo "3. Exit"
    echo "Enter your choice:"
    read ch

    case $ch in
        1) create_account ;;
        2) login ;;
        3) exit ;;
        *) echo "Invalid Choice!" ;;
    esac
done

