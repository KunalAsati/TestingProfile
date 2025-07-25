import { LightningElement, track } from 'lwc';
import addTodo from '@salesforce/apex/todoController.addTodo';
import getCurrentTodos from '@salesforce/apex/todoController.getCurrentTodos';
export default class Todocmp extends LightningElement {
    
    time = "9:40 PM";
    greeting = "Good Evening";
    @track todos = [];
    connectedCallback(){
        this.getTime();

        this.fetchTodos();
        // this.populateItems();
        setInterval(() => {
            this.getTime();
          }, 1000 * 60);
    }
    getTime() {
        const date = new Date(); /* creating object of Date class */
        const hour = date.getHours();
        const min = date.getMinutes();
    
        this.time = `${this.getHour(hour)}:${this.getDoubleDigit(
          min
        )} ${this.getMidDay(hour)}`;
        //get greeting (mornig/afternoon/evening/)
        this.setGreeting(hour);
    }

    setGreeting(hour) {
        if (hour < 12) {
            this.greeting = "Good Morning";
        } else if (hour >= 12 && hour < 17) {
            this.greeting = "Good Afternoon";
        } else {
            this.greeting = "Good Evening";
        }
    }
    getHour(hour) {
        return hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    }
    getMidDay(hour) {
        return hour >= 12 ? "PM" : "AM";
    }
    getDoubleDigit(digit) {
        return digit < 10 ? "0" + digit : digit;
    }
    
    addTodoHandler(){
        const inputBox = this.template.querySelector("lightning-input");
        

        const todo = {
            todoName : inputBox.value,
            done: false,
        };

        addTodo({payload: JSON.stringify(todo)} ).then(response =>{

            console.log("Item Inserted");
            this.fetchTodos();

        }).catch(error=>{
            console.error('Error in inserting a item' +error);
        })
        this.todos.push(todo);
        inputBox.value = "";
    }

    // get property to return upcoming/unfinished todos
    get upcomingTodos() {
        return this.todos && this.todos.length
        ? this.todos.filter(todo => !todo.done)
        : [];
    }

    // get property to return completed todos
    get completedTodos() {
        return this.todos && this.todos.length
        ? this.todos.filter(todo => todo.done)
        : [];
    }


    fetchTodos(){

        getCurrentTodos().then(result=>{

            if(result){
                console.log(" Todos Length: " + result.length);
                this.todos = result
            }
        }).catch(error=>{
            console.error('Error in inserting a item' +error);
        })
    }
    updateHandler(){

        this.fetchTodos();
    }
    deleteHandler(){

        this.fetchTodos();
    }
    populateItems(){
        const todose = [
            {
                todoId: 0,
                todoName : "Pahila Item",
                done: false,
                todoDate: new Date()
            },
            {
                todoId: 1,
                todoName : "Dusra Item",
                done: false,
                todoDate: new Date()
            },
            {
                todoId: 2,
                todoName : "Tisra Item",
                done: true,
                todoDate: new Date()
            }
        ];
        this.todos = todose;
    }

}