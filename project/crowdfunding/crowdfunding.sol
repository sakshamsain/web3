// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
contract crowdfunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public miniContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public remainAmount;
    uint public noContributors;

    struct Request{
            string description;
            address payable recipient;
            uint value;
            bool completed;
            uint noOfvoters;
            mapping(address=>bool) voters;

    }
    constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        miniContribution = 100;
        manager = msg.sender;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;
    function sendEth() public  payable{
            require(block.timestamp< deadline, "your late for this");
            require(msg.value>= miniContribution, "given amount is too low");
            if(contributors[msg.sender]==0){
                noContributors++;
            }
            contributors[msg.sender] += msg.value; // if a same contributor pay more than one time
            raisedAmount += msg.value;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp> deadline && raisedAmount< target, "deadline not met yet");
        require(contributors[msg.sender]>0,"you are not a contributor");
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender == manager,"only manafer is allowed");
        _;
    }
    function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManager{
               Request storage newRequest = requests[numRequests];// new request points the struct which finally make change in request[index] index is 0,1,2,3,4,5.....
               numRequests++;
               newRequest.description = _description;
               newRequest.recipient = _recipient;
               newRequest.value = _value;
               newRequest.completed = false;
               newRequest.noOfvoters = 0;


    }
    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender]>0, "not eligible");
       
        Request storage thisRequest =requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfvoters++;

    }
    function makepyment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target,"return");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed ==false, "done already");
        require(thisRequest.noOfvoters> noContributors/2);
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;

    }
}
//  CA -0x99CF4c4CAE3bA61754Abd22A8de7e8c7ba3C196d
//  MA -0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
