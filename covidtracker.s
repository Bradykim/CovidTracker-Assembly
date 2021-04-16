.text
.align 2
#Main Code
# prompt the user to enter the patient 
# then prompt the user to enter the infected
# if the patient is equivalent to DONE, then Break
# pass the patient, infected and root as arguments
# continually loop until the condition is met
main:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
   

    la $a1, bluedevil
    jal makeTreeNode
    sw $v0, 4($sp)

    loop:
    #Gets the first prompt and passes it through patient
        li $v0, 4
        la $a0, patient_prompt
        syscall

        la $a0, patient
        jal strclr

        li $v0, 8
        la $a0, patient
        li $a1, 20
        syscall

    #Checks if the value returned from patient equals DONE
        la $a0, done
        la $a1, patient
        jal strcmp
        
        li $t3, 0
        beq $v0, $t3, afterloop


        
    #Gets the second prompt and passes it through infecter
        li $v0, 4
        la $a0, infecter_prompt
        syscall

        la $a0, infector
        jal strclr
        
        li $v0, 8
        la $a0, infector
        li $a1, 20
        syscall
        
    
        la $a0, patient
        la $a1, infector
        lw $a2, 4($sp)
        jal makeTree
    j loop

    afterloop:

        lw $a0, 4($sp)
        jal printTree

        
        lw $s0, 4($sp)
        lw $ra 0($sp)
        addi $sp, $sp, 8
        jr $ra


# Allocate memory when a TreeNode is dynamically created.
# Set the info equal to the value given.
# Set the right and left pointers to NULL.
# Return the TreeNode
#use a buffer and put into source register
makeTreeNode:
    addi $sp, $sp, -8
    sw $ra, 0($sp)

    move $t2, $a1

    #malloc space for a new treenode
    li $a0, 28
    li $v0, 9
    syscall

    sw $v0, 4($sp)
    lw $s1, 4($sp)

    #load the address of $v0 into $a0 and use it as the first argument for strcpy (the destination)
    move $a0, $s1

    #move the patient name to $a1 so it can be copied
    move $a1, $t2
    jal strcpy

    #set the final 8 bytes to left and right pointers
    sw $zero, 20($s1)
    sw $zero, 24($s1)

    #return the address of the created node
    move $v0, $s1

    lw $s1, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra

# Recursively loop through the binary tree.
# Find where the value equals the infector.
# Create a new node with the info=infected at that location.
# Send in two strings representing infected and infector.
makeTree:
    addi $sp, $sp, -16
    sw $ra, 0($sp)

    # set 8($sp)= to patient
    # set 12($sp) = to infecter
    # set s2 = to the bluedevil root
    # set t6 = to root.left
    # set t7 = to root.right
    sw $a0, 8($sp)
    sw $a1, 12($sp)
    sw $a2, 4($sp)
  
  

    recurse:
       
        #check if the value at the bluedevil root is equal to null
        beq $a2, $zero, end

        #check if the value at bluedevil is equal to infecter
        move $a0, $a2
        lw $a1, 12($sp)
        jal strcmp
        bnez $v0, continue

        #pass the patient to makeTreeNode
        lw $a1, 8($sp)
        jal makeTreeNode

        # move the returned treenode into t3
        move $t3, $v0
        lw $s2, 4($sp)
        lw $t4, 20($s2)
        lw $t5, 24($s2)

        #if the left is empty, put it into left
        bne $t4, $zero, next1
        sw $t3, 20($s2)
        j end

        #if the left has something, check if this node is greater than that value, if it is, put into right
        #if not, call swap left
        next1:
        move $a0, $t3
        move $a1, $t4
        jal strcmp
        bltz $v0, swapleft
        sw $t3, 24($s2)
        j end

        #put this into the left and the treenode that was in the left into the right
        swapleft:
        move $t7, $t4
        sw $t3, 20($s2)
        sw $t7, 24($s2)

        #if the right is empty, put the value of the new Tree node in the parent node.right
        
        lw $s2, 4($sp)
        sw $t3, 20($s2)
        
    continue:
        #call maketree to the left
        lw $a0, 8($sp)
        lw $a1, 12($sp)
        lw $s2, 4($sp)
        lw $a2, 20($s2)
        jal makeTree

        #call maketree to the right
        lw $a0, 8($sp)
        lw $a1, 12($sp)
        lw $s2, 4($sp)
        lw $a2, 24($s2)
        jal makeTree
    end: 
        lw $s2, 4($sp)
        lw $ra, 0($sp)
        addi $sp, $sp, 16
        jr $ra

    

printTree:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)

  
    beq $a0, $zero, next

    
    li $v0, 4
    lw $a0, 4($sp)
    syscall
    
    #call printtree left
    lw $s0, 4($sp)
    lw $a0, 20($s0)
    jal printTree


    #call printtree right
    lw $s1, 4($sp)
    lw $a0, 24($s1)
    jal printTree
    
    next:
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra
    
    

strcmp:
	lb $t0, 0($a0)
	lb $t1, 0($a1)

	bne $t0, $t1, done_with_strcmp_loop
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	bnez $t0, strcmp
	li $v0, 0
	jr $ra
		

	done_with_strcmp_loop:
	sub $v0, $t0, $t1
	jr $ra

strcpy:
	lb $t0, 0($a1)
	beq $t0, $zero, done_copying
	sb $t0, 0($a0)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j strcpy

	done_copying:
	jr $ra


strclr:
	lb $t0, 0($a0)
	beq $t0, $zero, done_clearing
	sb $zero, 0($a0)
	addi $a0, $a0, 1
	j strclr

	done_clearing:
	jr $ra

.align 2
.data

patient_prompt: .asciiz "Please enter patient: "
infecter_prompt: .asciiz "Please enter an infecter: "
done: .asciiz "DONE\n"
bluedevil: .asciiz "BlueDevil\n"

patient:

    .space 20

infector:

    .space 20
