// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract demo {
    address public operator;
    struct Tweet{
    uint ID;
    address author;
    string content;
    uint timestamp;
}
    struct Message{
    uint ID;
    string content;
    address sender;
    address receiver;
    uint timestamp;
}
    mapping(address=>Tweet) public tweets;
    mapping(address=>uint[]) public tweetof;
    mapping(address=>Message[]) public conversation;
    // mapping(address=>)
    mapping(address=>address[]) public following;





    function _tweet(address _from, string memory _content) internal {
      require(_from == msg.sender || operator[_from][msg.sender],"you have no right");
        tweet[nextId]= Tweet(nextId, _from, _content, block.timestamp);
        tweetof[_from].push[nextId];
        nextId++;
    }
   
    function _sendMessage(address _from, address _to, string memory _content) internal {
        require(_from == msg.sender || operator[_from][msg.sender],"you have no right");
        conversation[_from].push(Message(nextmsgId,_from,_to,_content,block.timestamp));
        nextmsgId++;
    }
    // uint ID;
    // address author;
    // string content;
    // uint timestamp;
    function tweet(string memory _content) public {
         _tweet(msg.sender, _content);
    }
    function tweet(address _from, string memory _content)  public {
        _tweet(_from, _content);
    }
    function sendMessage(address _to ,string memory _content) public {
        _tweet(msg.sender,_to, _content);
        
    }
    function sendMessage(address _from, address _to, string memory _content) public{
        _tweet(_from,_to, _memory);
    }
    function follow(address _followed) public{
        following[msg.sender].push(_followed);
    }
    function allow(address _operator) public {

    }
    function disallow(address _operator) public {

    }
    function getLatestTweets(uint count) public {
    //      uint ID;
    // address author;
    // string content;
    // uint timestamp;
    _tweet()
    }
}
