// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract main
{
    mapping(address => User) private login;

    struct User
    {
        string nickname;
        uint[] questionsAsked;
        uint[] questionsAnswered;
    }

    struct Question
    {
        uint id;
        address author;
        string subject;
        string content;
        address[] upVoters;
        address[] downVoters;
        Answer[] answers;
    }

    struct Answer
    {
        uint id;
        address author;
        string content;
        address[] upVoters;
        address[] downVoters;
    }

    struct Pack
    {
        uint id;
        string text;
        int repupation;
    }

    Question[] private questions;
    uint numQuestions;
    Question auxQuestion;
    Answer auxAnswer;

    function makeQuestion(string memory subject, string memory content) public
    {
        require(keccak256(abi.encodePacked(subject)) != keccak256(abi.encodePacked("")), "Subject cannot be empty");
        auxQuestion.id = numQuestions;
        auxQuestion.author = msg.sender;
        auxQuestion.subject = subject;
        auxQuestion.content = content;
        questions.push(auxQuestion);
        User storage user = login[msg.sender];
        user.questionsAsked.push(numQuestions);
        numQuestions++;
    }

    function makeAnswer(uint questionId, string memory content) public
    {
        require(keccak256(abi.encodePacked(content)) != keccak256(abi.encodePacked("")), "Please give him bizu!");
        auxAnswer.id = questions[questionId].answers.length;
        auxAnswer.author = msg.sender;
        auxAnswer.content = content;
        questions[questionId].answers.push(auxAnswer);
        User storage user = login[msg.sender];
        user.questionsAnswered.push(questionId);
    }

    function has(address[] memory array, address value) pure private returns(int)
    {
        for (uint i = 0; i < array.length; ++i)
        {
            if (array[i] == value)
                return int(i);
        }
        return -1;
    }

    function remove(address[] storage array, address value) private
    {
        int index = has(array, value);
        if (index != -1)
        {
            array[uint(index)] = array[array.length - 1];
            array.pop();
        }
    }

    function doUpvoteQ(uint questionId) public
    {   
        require(has(questions[questionId].upVoters, msg.sender) == -1, "You already upvoted this question");
        remove(questions[questionId].downVoters, msg.sender);
        questions[questionId].upVoters.push(msg.sender);
    }

    function doDownvoteQ(uint questionId) public
    {
        require(has(questions[questionId].downVoters, msg.sender) == -1, "You already downvoted this question");
        remove(questions[questionId].upVoters, msg.sender);
        questions[questionId].downVoters.push(msg.sender);
    }

    function doUpvoteA(uint questionId, uint answerId) public
    {
        require(has(questions[questionId].answers[answerId].upVoters, msg.sender) == -1, "You already upvoted this answer");
        remove(questions[questionId].answers[answerId].downVoters, msg.sender);
        questions[questionId].answers[answerId].upVoters.push(msg.sender);
    }

    function doDownvoteA(uint questionId, uint answerId) public
    {
        require(has(questions[questionId].answers[answerId].downVoters, msg.sender) == -1, "You already downvoted this answer");
        remove(questions[questionId].answers[answerId].upVoters, msg.sender);
        questions[questionId].answers[answerId].downVoters.push(msg.sender);
    }

    function getReputationQ(uint questionId) view public returns(int)
    {
        return int(questions[questionId].upVoters.length) - int(questions[questionId].downVoters.length);
    }

    function getReputationA(uint questionId, uint answerId) view public returns(int)
    {
        return int(questions[questionId].answers[answerId].upVoters.length) - int(questions[questionId].answers[answerId].downVoters.length);
    }
    
    function getQuestions() public view returns(Pack[] memory)
    {
        Pack[] memory packs = new Pack[](questions.length);
        for (uint i = 0; i < questions.length; ++i)
        {
            packs[i].id = questions[i].id;
            packs[i].text = questions[i].subject;
            packs[i].repupation = getReputationQ(questions[i].id);
        }
        return packs;
    }

    function getQuestion(uint questionId) public view returns(Question memory)
    {
        return questions[questionId];
    }

    function getMyQuestions() public view returns(Pack[] memory)
    {
        User storage user = login[msg.sender];
        Pack[] memory packs = new Pack[](user.questionsAsked.length);
        for (uint i = 0; i < user.questionsAsked.length; ++i)
        {
            packs[i].id = user.questionsAsked[i];
            packs[i].text = questions[user.questionsAsked[i]].subject;
            packs[i].repupation = getReputationQ(user.questionsAsked[i]);
        }
        return packs;
    }

    function getMyAnsweredQuestions() public view returns(Pack[] memory)
    {
        User storage user = login[msg.sender];
        Pack[] memory packs = new Pack[](user.questionsAnswered.length);
        for (uint i = 0; i < user.questionsAnswered.length; ++i)
        {
            packs[i].id = user.questionsAnswered[i];
            packs[i].text = questions[user.questionsAnswered[i]].subject;
            packs[i].repupation = getReputationQ(user.questionsAnswered[i]);
        }
        return packs;
    }

    function getNickname() public view returns(string memory)
    {   
        User storage user = login[msg.sender];
        return user.nickname;
    }

    function showUser() public view returns(User memory)
    {   
        User storage user = login[msg.sender];
        return user;
    }
}