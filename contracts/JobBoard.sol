// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract JobBoard {
  struct Job {
    uint256 id;
    string title;
    string description;
    uint256 reward;
    address employer;
    address[] applications;
    bool isCompleted;
  }

  struct Application {
    uint256 jobId;
    address applicant;
    string ipfsHash;
    bool isAccepted;
  }

  mapping(uint => Job) public jobs;
  mapping(uint => Application) public applications;

  uint256 public jobCount;
  uint256 public applicationCount;

  constructor () {
    jobCount = 0;
    applicationCount = 0;
  }

  event JobPosted(uint256 jobId, string title, address employer);
  event JobApplied(uint256 applicationId, uint256 jobId, address applicant);
  event JobCompleted(uint256 jobId);
  event ApplicationAccepted(uint256 applicationId);

  function postJob(string memory _title, string memory _description, uint256 _reward) public {
    jobCount++;
    jobs[jobCount] = Job(jobCount, _title, _description, _reward, msg.sender, new address[](0), false);
    emit JobPosted(jobCount, _title, msg.sender);
  }

  function applyForJob(uint256 _jobId, string memory _ipfsHash) public {
    require(_jobId > 0 && _jobId <= jobCount, "Invalid job ID");
    applicationCount++;
    applications[applicationCount] = Application(_jobId, msg.sender, _ipfsHash, false);
    jobs[_jobId].applications.push(msg.sender);
    emit JobApplied(applicationCount, _jobId, msg.sender);
  }

  function acceptApplication(uint256 _applicationId) public {
    Application storage application = applications[_applicationId];
    Job storage job = jobs[application.jobId];
    require(msg.sender == job.employer, "Only employer can accept applications");
    require(job.isCompleted == false, "Job is already completed");

    application.isAccepted = true;
    job.isCompleted = true;

    payable(application.applicant).transfer(job.reward);

    emit ApplicationAccepted(_applicationId);
    emit JobCompleted(application.jobId);
  }

  receive() external payable {}
}