// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address public manager;
    address payable[] public participants;  //dynamic array of participants that holds the address of participants

    constructor()
    {
        /* msg.sender is a global variable that hold the address of 
            sender when manager deploys the contract its address will
            be store in the manager state variable.
            So manager will have full control over the contract bcz
            he deploys the contract.
        */
        manager=msg.sender;
    }

    /* we create a payable function by which we will transfer the
       ethers send by the participants into our smart contract. 

       receive() external payable this function is special type of built-in-function
       that is used to transfer ether to our smart contract.

       when ever a participant send ether it will automattically call 
       this receive funtion and ether is transfered to our contract.
    */
    receive() external payable{

        /*this require is built-in functionality of solidity that is kindof
        similar to if-else
        this will check if the participants transfered ether amount>2 if yes
        particitants address will be pushed in side the participant array
        else participant is not eligibal to participate. 
        */
        require(msg.value==2 ether); 
        participants.push(payable(msg.sender));
    }

    /*function to check balance of our smart contract */
    function Get_Balance() view public returns(uint )
    {
        /*
        only manager can check the contract balance.
        */
        require(msg.sender==manager);
        return address(this).balance;
    }

    function random() view public returns(uint)
    {
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));
    }

    function Select_Winner() public 
    {
        /*
        Only manager can select the winner.
        */
        require(msg.sender==manager);
        /*
        there should be atleast 3 participants to start the lottery.
        */
        require(participants.length>=3);

        /*
        stores a randon number in r.
        */
        uint  r=random();
        address payable winner; // hold address of winner account
        /*
        This index variable will store index of winner participant
        random number mode with total number of participants will give index
        of winner participants
        */
        uint index= r % participants.length;

        /*
        stores the address of winning participant in winner variable
        */
        winner=participants[index];

        /*
        Tranfer the all the contract balance to the winner account.
        */
        winner.transfer(Get_Balance());

        /*
        Resetting the participants array i.e remove all the participants 
        because winner has been selected now we have to remove the participants 
        from our array.
        */
        participants= new address payable[](0);
    }
}
