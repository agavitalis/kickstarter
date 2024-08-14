// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract CampaignFactory{

    address[]  public  deployedCampaigns;

    function createCampaign(uint minimum) public{
        address newCampaign = new Campaign(minimum,msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaign() public view returns(address[] memory){
         return  deployedCampaigns;
    }

}

contract Campaign{

    struct Request{
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        uint disapprovalCount;
        mapping(address=>bool) approvals;
    }

    address public manager;
    uint public minimumContribution;
    mapping(address=>bool) public approvers;
    uint public approvalCount;

    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

    constructor(uint  minimum, address createor) {
        manager = createor;
        minimumContribution = minimum;
    }
   
   function contribute() public payable{
       require(msg.value > minimumContribution);
       approvers[msg.sender] = true;
       approvalCount++;
   }

    uint numRequests;
    mapping (uint => Request) requests;
    
    function createRequest(string memory description, uint value, address recipient) public restricted {            
        Request storage r = requests[numRequests++];
        r.description = description;
        r.value = value;
        r.recipient = recipient;
        r.complete = false;
        r.approvalCount = 0;
    }

    function approveRequest(uint index) public {

        require(approvers[msg.sender]);
        require(!requests[index].approvals[msg.sender]);

        requests[index].approvals[msg.sender] = true;
        requests[index].approvalCount++;
    }

    function finalizeRequest(uint index) public restricted{

        Request storage request = requests[index];
        require (!request.complete);
        request.complete = true;
    }

}