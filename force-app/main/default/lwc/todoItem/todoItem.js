import { LightningElement, api } from 'lwc';
import updateTodo from '@salesforce/apex/todoController.updateTodo';
import deleteTodo from '@salesforce/apex/todoController.deleteTodo';


export default class TodoItem extends LightningElement {


    @api todoId;
    @api todoName;
    @api done= false;

    get containerClass(){
        return this.done ? "todo completed" :"todo upcoming";
    }

    get iconName(){
        return this.done ? "utility:check" :"utility:add";
    }

    updateHandler(){

        const todo = {
            todoId : this.todoId,
            todoName : this.todoName,
            done : !this.done
        };
        updateTodo({payload: JSON.stringify(todo)}).then(result=>{
            console.log("Item Updated");

            const updateEvent = new CustomEvent("update");
            this.dispatchEvent(updateEvent);

        }).catch(error=>{
            console.error("Updating error occured : "+ error);
        });
    }

    deleteHandler(){

        deleteTodo({todoId: this.todoId}).then(result=>{
            console.log("Item Deleted");
            const deleteEvent = new CustomEvent("delete");
            this.dispatchEvent(deleteEvent);
        }).catch(error=>{
            console.error("Updating error occured : "+ error);
        });
    }
}