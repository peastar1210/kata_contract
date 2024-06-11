import { expect } from "chai";
import { Address } from "cluster";
import hre from "hardhat";
import { ethers } from "hardhat";

describe("JobBoard Contract", function () {
	let JobBoard;
	let staking;
	let jobBoard: any;
	let employer: any;
	let applicant1;

	this.beforeEach(async function () {
		jobBoard = await hre.ethers.deployContract("JobBoard");
		staking = await hre.ethers.deployContract("Staking");
		[employer] = await ethers.getSigners();
	});

	describe("postJob", function () {
		it("should post job correctly", async function () {
			await jobBoard
				.connect(employer)
				.postJob(
					"Full Stack Developer",
					"I am looking for an experienced full stack developer",
					100
				);

			const job = await jobBoard.jobs(1);

			expect(job.id).to.equal(1);
			expect(job.title).to.equal("Full Stack Developer");
			expect(job.description).to.equal(
				"I am looking for an experienced full stack developer"
			);
			expect(job.reward).to.equal(100);
			expect(job.employer).to.equal(employer.address);
		});

		it("should emit JobPosted event correctly with values", async function () {
			await expect(
				jobBoard
					.connect(employer)
					.postJob(
						"Full Stack Developer",
						"I am looking for an experienced full stack developer",
						1
					)
			)
				.to.emit(jobBoard, "JobPosted")
				.withArgs(1, "Full Stack Developer", employer.address);
		});
	});
});
