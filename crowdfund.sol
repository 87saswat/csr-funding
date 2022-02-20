//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.9.0;

contract CrowdFund{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recepient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=> bool) voters;
    }

    mapping(uint=>Request) public requests;
    uint public numRequests;
    

    modifier onlyManager(){
        require(msg.sender==manager, "Only manager can call this function");
        _;
    }function createRequest(string memory _description, address payable _recepient, uint _value)public onlyManager{
        Request storage newRewquest = requests[numRequests];
        numRequests++;
        newRewquest.description=_description;
        newRewquest.recepient=_recepient;
        newRewquest.value=_value;
        newRewquest.completed=false;
        newRewquest.noOfVoters=0;
    }

    function voterequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You can't vote wothout contributing");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]==true;
        thisRequest.noOfVoters++;

    }

    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount >= target," ");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false, "AMount already paid request completed");
        require(thisRequest.noOfVoters > noOfContributors/2, "You need more than 50% of vote for majority");
        thisRequest.recepient.transfer(thisRequest.value);
        thisRequest.completed==true;


    }

    constructor(uint _target, uint _deadline) {
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution= 100 wei;
        manager=msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp<deadline, "Deadline has passed!!");
        require(msg.value>=minimumContribution,"Minimum contribution is 1 ether");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target, "Not elegible for refund as criteria are not met!!");
        require(contributors[msg.sender]>0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

   
}