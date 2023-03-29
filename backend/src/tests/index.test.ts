import { expect } from "chai";
import { describe } from "mocha";
import { add } from "..";

describe('add', () => {
    it('sould return a postive number for positive input', () => {
        expect(add(1, 5)).to.equal(6);
    });
    it('sould return a negative number for negative input', () => {
        expect(add(-1, -5)).to.equal(-6);
    });
    it('sould throw an error', () => {
        expect(add(0, 0)).to.throw(new Error());
    });
});
