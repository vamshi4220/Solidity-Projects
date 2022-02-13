//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.9.0;

contract CroudFunding {
    mapping(address => uint256) public contributer;
    uint256 public minimumcontrubution;
    uint256 public target;
    uint256 public deadline;
    uint256 public numc;
    uint256 public ramount;
    address public manager;

    constructor(uint256 _targe, uint256 _deadline) public {
        target = _targe;
        deadline = block.timestamp + _deadline;
        minimumcontrubution = 1000 wei;
        manager = msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline, "too late");
        require(
            msg.value >= minimumcontrubution,
            "too low contribution to allow"
        );
        if (contributer[msg.sender] == 0 && ramount <= target) {
            numc++;
        }
        if (ramount <= target) {
            if (msg.value <= target - ramount)
                contributer[msg.sender] += msg.value;
            else revert("decrese your contribution!!");
        } else revert("target achived");
        ramount += msg.value;
    }

    struct Request {
        string description;
        uint256 value;
        address payable recipient;
        uint256 noOfVoters;
        bool completed;
        mapping(address => bool) voters;
    }
    mapping(uint256 => Request) public requests;
    uint256 public numRequests;

    function refund() public payable {
        require(
            block.timestamp < deadline && ramount < target,
            "you are not eligible for refund"
        );
        require(contributer[msg.sender] > 0, "nothing to refund");
        address payable refundreq = payable(msg.sender);
        refundreq.transfer(contributer[msg.sender]);
        numc--;
        contributer[msg.sender] = 0;
    }

    function createRequests(
        string memory _description,
        address payable _recipient,
        uint256 _value
    ) public onlyManger {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint256 _requestNo) public {
        require(contributer[msg.sender] > 0, "YOu must be contributor");
        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.voters[msg.sender] == false,
            "You have already voted"
        );
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint256 _requestNo) public onlyManger {
        require(ramount >= target);
        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.completed == false,
            "The request has been completed"
        );
        require(thisRequest.noOfVoters > numc / 2, "Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }

    modifier onlyManger() {
        require(msg.sender == manager, "only manager can access");
        _;
    }

    function getValue() public view returns (uint256) {
        return address(this).balance;
    }
}
