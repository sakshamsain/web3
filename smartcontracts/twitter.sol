//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Twiiter {
    uint16 public MAX_TWEET_LENGTH =280;
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }
    mapping(address=> Tweet[]) public tweets;
    address public owner;
    constructor(){
owner =msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"YOU ARE NOT THE OWNER!");
        _;
    }
    function changeTweetLength(uint16 newTweetLength) public onlyOwner{
MAX_TWEET_LENGTH =newTweetLength;
    }
    function createTweet(string memory _tweet) public {
        // conditional
        // if tweet length <=200 then we are good , otherwise we revert 
        require(bytes(_tweet).length<=MAX_TWEET_LENGTH, "Tweet is too long bro!"); //we use byte because we know every ascii character takes one byte only

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });
        tweets[msg.sender].push(newTweet);
    }
    function likeTweet(address author, uint256 id) external{
        require(tweets[author][id].id==id,"TWEET DOESN'T EXIST");
        
tweets[author][id].likes++;

    }
    function unlikeTweet(address author, uint256 id) external{
        require(tweets[author][id].id==id, "TWEET DOESN'T EXIST");
        require(tweets[author][id].likes>0,"TWEET HAS NO LIKES");
        
        tweets[author][id].likes--;
    }
        //msg is the used to store metamask data and other information 
        function getTweet(uint _i) public view returns(Tweet memory){
          return  tweets[msg.sender][_i];
        }
    function getAllTweets(address _owner) public view returns (Tweet[] memory){
        return tweets[_owner];
    }
}
