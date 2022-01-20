//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    enum AnimalType { INVALID, FISH, CAT, DOG, RABBIT, PARROT }
    enum GenderType {MALE, FEMALE}
    address owner;


    mapping (AnimalType => uint) public AnimalToCount;
    mapping (address => AnimalType) borrowerToAnimalType;
    mapping (address => uint) borrowerToAge;
    mapping (address => GenderType) borrowerToGender;


    event Added(AnimalType _animalType, uint _count);
    event Borrowed(AnimalType _animalType);
    event Returned(AnimalType _animalType);


    constructor() {
      owner = msg.sender;
    }


    function add (AnimalType animalType, uint count) public {
        if(msg.sender != owner) { revert("Not an owner"); }
        if (animalType == AnimalType.INVALID || animalType > AnimalType.PARROT) { revert("Invalid animal"); }
        AnimalToCount[animalType] = count;
        emit Added(animalType, count);
    }

    function borrow (uint age, GenderType gender, AnimalType animalType) public {

        if (age == 0) { revert("Invalid Age"); }
        if (animalType == AnimalType.INVALID || animalType > AnimalType.PARROT) { revert("Invalid animal type"); }
        if (AnimalToCount[animalType] == 0) { revert("Selected animal not available"); }

        if (borrowerToAge[msg.sender] == 0) {
            borrowerToAge[msg.sender] = age;
            borrowerToGender[msg.sender] = gender;
        }

        if (borrowerToAge[msg.sender] != age) {
            revert("Invalid Age");
        }

        if (borrowerToGender[msg.sender] != gender) {
            revert("Invalid Gender");
        }

        if (borrowerToAnimalType[msg.sender] != AnimalType.INVALID) {
            revert("Already adopted a pet");
        }

        if (gender == GenderType.MALE) {
            if (animalType == AnimalType.CAT || animalType == AnimalType.RABBIT || animalType == AnimalType.PARROT) {
                revert("Invalid animal for men");
            }
        }

        if (gender == GenderType.FEMALE) {
            if (age < 40 && animalType == AnimalType.CAT) {
                revert("Invalid animal for women under 40");
            }
        }

        AnimalToCount[animalType] -= 1;
        borrowerToAnimalType[msg.sender] = animalType;

        emit Borrowed(animalType);

    }

    function giveBackAnimal () public {

        AnimalType animalType;

        if (borrowerToAnimalType[msg.sender] == AnimalType.INVALID) {
            revert("No borrowed pets");
        }

        require(borrowerToAnimalType[msg.sender]  != AnimalType.INVALID);

        animalType = borrowerToAnimalType[msg.sender];

        AnimalToCount[animalType] += 1;

        borrowerToAnimalType[msg.sender] = AnimalType.INVALID;

        emit Returned(animalType);

    }

    function animalCounts (AnimalType animalType) public view returns(uint) {
        return (AnimalToCount[animalType]);
    }

}

