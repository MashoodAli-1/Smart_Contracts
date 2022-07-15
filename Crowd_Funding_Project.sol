// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

struct Request{
    string description;
    address payable recipient;
    uint value;
    bool completed;
    uint noOfVoters;
    mapping(address=>bool) Voters;
}


contract Crowd_funding{
    /*
    Address is mapped to total ethers a contributor is contributing.
    address -> ethers

    Contributor[msg.sender] gives ether amount of the contributor.

    msg.sender gives the address of the current contributor.

    */
    mapping(address=>uint) public contributors; // address -> ethers
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    mapping(uint=>Request) public requests;
    uint public noOfRequest;
    /*
    Manager will define the deadline and target 
    when he deploys the smart contract.  
    */
    constructor(uint _target,uint _deadline)
    {
        target=_target;
        deadline=block.timestamp + _deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    }
    /*
    By this function contribution of contributors will be store in the 
    smart contract.
    */
    function sendEther() public payable{
        /*
        this require will check if the deadline has passed or not
        if deadline has been passed then contract will not 
        store more ethers
        */
        require(block.timestamp < deadline,"Deadline has passed");
        /*
        this require will check if the contributor's contribution
        is greater or equal to the minimum_contribution. 
        if the contribution is less than the require value
        contract will not store or accept the ether.
        */
        require(msg.value >= minimumContribution,"Minimum Contribution is not met");
        
        /*
        If we found the new contributor 
        we increment the noOfContributor.
        if the same contributor contributes second or n-times
        it will not increase the no.Of Contributors
        */
        if(contributors[msg.sender]==0)
        {
            noOfContributors++;
        }

        /*
        if same contributor again  contributes. 
        */
        contributors[msg.sender] = contributors[msg.sender] + msg.value;

        raisedAmount += msg.value;
    }

     /*function to check balance of our smart contract */
    function Get_Contract_Balance() view public returns(uint){
        return address(this).balance;
    }


    /*
    this function will refund the contributor his ethers
    if the deadline is passed and target is not met. 
    */
    function refund() public{
        /*
        This require check if the deadline has passed and target has met
        or not.
        */
        require(block.timestamp >= deadline && raisedAmount < target, "Your cannot refund your money before the deadline");
        /*
        This require will check if the contributor has funded ethers 
        before.
        */
        require(contributors[msg.sender]>0,"You mus be a Contributor! ");
        
        /*
        if all the condition satisfied the contributor is now eligible to 
        refund his ethers.
        */
        address payable eligible_contributor = payable(msg.sender);
        /*
        refunding ether of contributor.
        */
        eligible_contributor.transfer(contributors[msg.sender]);

        /*
        Now ethers have been refunded to the contributor 
        so now we have to reset the account of the contributor.
        */
        contributors[msg.sender]=0;

    }

    modifier onlyManager(){
        require(msg.sender == manager,"Only manager can call this function");
        _; // ending of modifier;
    }
	

    /*
    through this function manager will create 
    a request for a firm.
     
    */

    function Create_Request(string memory _description,address payable _recipient,uint _value) public onlyManager{
        Request storage newRequest = requests[noOfRequest];
        noOfRequest++;
        newRequest.description=_description;
        newRequest.recipient=_recipient; 
        newRequest.value=_value; 
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    } 

    /*
    Through this function a contributor can vote for 
    a particular request_made_by_the_manager
    */
    function Vote_Request(uint _requestno) public
    {
        /*
        criteria for vote is that a person shoild be a contributor.
        This require will check if the person is contributor  or not
        */
        require(contributors[msg.sender]>0,"You must be a Contributor! ");
        
        Request storage thisRequest = requests[_requestno];
        /*
        this require will check if the contributor has voted before or not
        if contributor has already voted he can not vote for 
        same request twice. but he can vote for other requests
        but not on the  same request twice. 
        */
        require(thisRequest.Voters[msg.sender] == false, "you have already voted!");
        
        thisRequest.Voters[msg.sender]=true;
        
        /*
        it will count the total_no of votes for a particular 
        request.
        */
        thisRequest.noOfVoters++;
    }

    /*
    Through this function manager will make payment to 
    that firm for which he had pulled a request.
    but manager can only make this transection if and only is:
    -> Raised_Amount should be greater or equal to target_amount.
    -> Total_Number_Of_votes for that firms_request should be 
        greater than 50% of the no_of _contributors.
    -> That particular request should not be completed before.    
    */
    function Make_Payment(uint _requestno) public onlyManager{
        /*
        this require will check if the raised amount is greater than 
        target or not
        */
        require(raisedAmount >= target,"Raised amount is less than Target Amount");
        Request storage thisRequest = requests[_requestno];
        /*
        this require will check whether the particular firms_request 
        has been completed. if the request has been completed then
        no fund should be given to that particular firm.
        */
        require(thisRequest.completed == false, "This request has been completed");
        
        /*
        This require will check if the no of voter for that particular firm
        is greater than the 50% of the noof contributors. 
        */
        require(thisRequest.noOfVoters > noOfContributors/2, "Majority do not support this request");
        
        /*
        if the raised amount greater than target amount and
        the request was not completed and
        total no of voters for the request is greater than
        50% of no. of contributor
        then amount will be funded to that particular firm.
        */
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
        
        raisedAmount = raisedAmount - thisRequest.value;
    }

}
