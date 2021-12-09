// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract main
{
    mapping(address => User) private login;

    struct User
    {
        uint[] askedQuestions;
        uint[] answeredQuestions;
    }

    struct Question
    {
        uint id;
        address author;
        string subject;
        string content;
        Answer[] answers;
        int bestAnswer;
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
        auxQuestion.bestAnswer = -1; // Not selected
        questions.push(auxQuestion);
        User storage user = login[msg.sender];
        user.askedQuestions.push(numQuestions);
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
        if ( has(user.answeredQuestions, questionId) == -1 )
        {
            user.answeredQuestions.push(questionId);
        }
    }

    function has(uint[] memory array, uint value) pure private returns(int)
    {
        for (uint i = 0; i < array.length; ++i)
        {
            if (array[i] == value)
                return int(i);
        }
        return -1;
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

    function toggleUpvoteA(uint questionId, uint answerId) public
    {
        if (has(questions[questionId].answers[answerId].upVoters, msg.sender) == -1)
        {
            remove(questions[questionId].answers[answerId].downVoters, msg.sender);
            questions[questionId].answers[answerId].upVoters.push(msg.sender);
        }
        else {
            remove(questions[questionId].answers[answerId].upVoters, msg.sender);
        }
    }

    function toggleDownvoteA(uint questionId, uint answerId) public
    {
        if (has(questions[questionId].answers[answerId].downVoters, msg.sender) == -1)
        {
            remove(questions[questionId].answers[answerId].upVoters, msg.sender);
            questions[questionId].answers[answerId].downVoters.push(msg.sender);
        }
        else {
            remove(questions[questionId].answers[answerId].downVoters, msg.sender);
        }
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
        Pack[] memory packs = new Pack[](user.askedQuestions.length);
        for (uint i = 0; i < user.askedQuestions.length; ++i)
        {
            packs[i].id = user.askedQuestions[i];
            packs[i].text = questions[user.askedQuestions[i]].subject;
        }
        return packs;
    }

    function getMyAnsweredQuestions() public view returns(Pack[] memory)
    {
        User storage user = login[msg.sender];
        Pack[] memory packs = new Pack[](user.answeredQuestions.length);
        for (uint i = 0; i < user.answeredQuestions.length; ++i)
        {
            packs[i].id = user.answeredQuestions[i];
            packs[i].text = questions[user.answeredQuestions[i]].subject;
        }
        return packs;
    }

    function getMyReputation() public view returns(uint)
    {
        uint reputation = 0;
        User storage user  = login[msg.sender];
        for (uint i = 0; i < user.answeredQuestions.length; ++i)
        {
            uint questionId = user.answeredQuestions[i];
            int bestAnswerId = questions[questionId].bestAnswer;
            Answer[] memory answers = questions[questionId].answers;
            if (bestAnswerId > -1 && answers[uint(bestAnswerId)].author == msg.sender)
            {
                reputation++;
            }
        }
        return reputation;
    }

    function toggleBestAnswer(uint questionId, uint answerId) public
    {
        require(answerId < questions[questionId].answers.length);
        require(msg.sender == questions[questionId].author);
        if (questions[questionId].bestAnswer == int(answerId))
        {
            questions[questionId].bestAnswer = -1;
        }
        else {
            questions[questionId].bestAnswer = int(answerId);
        }
    }
}