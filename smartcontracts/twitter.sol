//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Twiiter {
    mapping(address=> string) public tweets;
    function createTweet(string memory _tweet) public {
        tweets[msg.sender]=_tweet;
    }
        //msg is the used to store metamask data and other information 
        function getTweet(address _owner) public view returns(string memory){
          return  tweets[_owner];
        }
    
}
