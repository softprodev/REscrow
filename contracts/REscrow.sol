// SPDX-License-Identifier: SoftProDev

pragma solidity ^0.7.1;


contract EscrowService  {
        //Version:  v1.0
        
        address public admin;

        
        //Each buyer address consist of an array of EscrowStruct
        //Used to store buyer's transactions and for buyers to interact with his transactions. (Such as releasing funds to seller)
        struct EscrowStruct
        {    
            address buyer;          //Person who is making payment
            address seller;         //Person who will receive funds
            address escrow_agent;   //Escrow agent to resolve disputes, if any
                                       
            uint escrow_fee;        //Fee charged by escrow
            uint amount;            //Amount of Ether (in Wei) seller will receive after fees

            bool escrow_intervention; //Buyer or Seller can call for Escrow intervention
            bool release_approval;   //Buyer or Escrow(if escrow_intervention is true) can approve release of funds to seller
            bool refund_approval;    //Seller or Escrow(if escrow_intervention is true) can approve refund of funds to buyer 

            bytes32 notes;             //Notes for Seller
            
        }

        struct TransactionStruct
        {                        
            //Links to transaction from buyer
            address buyer;          //Person who is making payment
            uint buyer_nounce;         //Nounce of buyer transaction                            
        }


        
        //Database of Buyers. Each buyer then contain an array of his transactions
        mapping(address => EscrowStruct[]) public buyerDatabase;

        //Database of Seller and Escrow Agent
        mapping(address => TransactionStruct[]) public sellerDatabase;       
        mapping(address => TransactionStruct[]) public escrowDatabase;
               
        //Every address have a Funds bank. All refunds, sales and escrow comissions are sent to this bank. Address owner can withdraw them at any time.
        mapping(address => uint) public Funds;

        mapping(address => uint) public escrowFee;


        //Constructor. Set contract creator/admin
        constructor() {
            admin = msg.sender;
        }

        function fundAccount(address sender_)  external payable
        {
            //LogFundsReceived(msg.sender, msg.value);
            // Add funds to the sender's account
            Funds[sender_] += msg.value;   
            
        }

        function setEscrowFee(uint fee) external{

            //Allowed fee range: 0.1% to 10%, in increments of 0.1%
            require (fee >= 1 && fee <= 100);
            escrowFee[msg.sender] = fee;
        }

        function getEscrowFee(address escrowAddress) internal view returns (uint) {
            return (escrowFee[escrowAddress]);
        }

       
}