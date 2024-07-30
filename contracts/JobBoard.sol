// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract JobBoard is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

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

  IERC20 public mainToken;
  IERC20 public jobToken;

  event JobPosted(uint256 jobId, string title, address employer);
  event JobApplied(uint256 applicationId, uint256 jobId, address applicant);
  event JobCompleted(uint256 jobId);
  event ApplicationAccepted(uint256 applicationId);

  constructor(
    address mainTokenAddress,
    address jobTokenAddress 
    ) Ownable()
  {
    require(mainTokenAddress != address(0), "Zero token address");
    require(jobTokenAddress != address(0), "Zero token address");
    jobCount = 0;
    applicationCount = 0;
    mainToken = IERC20(mainTokenAddress);
    jobToken = IERC20(jobTokenAddress);
  }

  function postJob(string memory _title, string memory _description, uint256 _reward) public {
    jobs[jobCount] = Job(jobCount, _title, _description, _reward, msg.sender, new address[](0), false);
    jobCount++;
    emit JobPosted(jobCount, _title, msg.sender);
  }

  function getJobs() external view returns (Job[] memory) {
    Job[] memory allJobs = new Job[](jobCount);
    
    for(uint256 i = 0; i < jobCount ; i++){
      allJobs[i] = jobs[i];
    }

    return allJobs;
  }

  function applyForJob(uint256 _jobId, string memory _ipfsHash) public {
    require(_jobId >= 0 && _jobId < jobCount, "Invalid job ID");
    require(msg.sender != jobs[_jobId].employer, "Employer cannot apply for their own job");
    
    bool hasApplied = false;
    for (uint256 i = 0; i < jobs[_jobId].applications.length; i++) {
        if (jobs[_jobId].applications[i] == msg.sender) {
            hasApplied = true;
            break;
        }
    }
    require(!hasApplied, "Applicant has already applied for this job");

    applications[applicationCount] = Application(_jobId, msg.sender, _ipfsHash, false);
    jobs[_jobId].applications.push(msg.sender);
    applicationCount++;

    require(jobToken.transferFrom(msg.sender, jobs[_jobId].employer, jobs[_jobId].reward.mul(10 ** 18)), "Token transfer failed");
    emit JobApplied(applicationCount, _jobId, msg.sender);
  }

  function getApplications(uint256 _jobId, address employerAddress) external view returns (Application[] memory) {
    require(jobs[_jobId].employer == employerAddress, "Only employer can see applications.");
    Application[] memory allApplications = new Application[](jobs[_jobId].applications.length);

    uint j = 0;
    for(uint256 i = 0; i < applicationCount ; i++){
      if(applications[i].jobId == _jobId) {
        allApplications[j] = applications[i];
        j++;
      }
    }

    return allApplications;
  }

  function acceptApplication(uint256 _applicationId) external {
    Application storage application = applications[_applicationId];
    Job storage job = jobs[application.jobId];
    require(msg.sender == job.employer, "Only employer can accept applications");
    require(job.isCompleted == false, "Job is already completed");

    application.isAccepted = true;
    job.isCompleted = true;

    require(jobToken.transferFrom(msg.sender, application.applicant, job.reward.mul(10 ** 18)), "Token transfer failed");

    emit ApplicationAccepted(_applicationId);
    emit JobCompleted(application.jobId);
  }

  receive() external payable {}
}