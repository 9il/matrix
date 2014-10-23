/**
Low level unsafe routines for BLAS.
*/
module simple_matrix;

import core.stdc.stdlib;
import core.stdc.string;

import std.traits : Unqual;
import std.range;
import std.algorithm : equal, copy;

///
struct Vector(T)
{
	///
	T* ptr;
	///
	size_t length;
	///
	ptrdiff_t shift;

	///
	mixin _D1!(Vector, T);

	ref inout(T) front() inout @property
	in
	{
		assert(length);
	}
	body
	{
		return ptr[0];
	}

	///
	void popFront()
	in
	{
		assert(length);
	}
	body
	{
		 ptr += shift;
		 length--;
	}

	///
	void popFrontN(size_t n)
	in
	{
		assert(length >= n);
	}
	body
	{
		 ptr += shift * n;
		 length -= n;
	}

	///
	ref inout(T) back() inout @property
	in
	{
		assert(length);
	}
	body
	{
		return ptr[shift * (length - 1)];
	}

	///
	void popBack()
	in
	{
		assert(length);
	}
	body
	{
		 length--;
	}

	///
	void popBackN(size_t n)
	in
	{
		assert(length >= n);
	}
	body
	{
		 length -= n;
	}

	///
	ref inout(T) opIndex(size_t index) inout
	in
	{
		assert(index < length);
	}
	body 
	{
		return ptr[shift*index];
	}

	///
	inout(Vector) opIndex(size_t[2] range) inout
	in
	{
		assert(range[1] <= length);
	}
	body 
	{
		return typeof(return)(ptr + range[0], range[1]-range[0], shift);
	}
}

///
unittest
{
	import std.range;

	alias VectorD = Vector!double;

	static assert(is(ElementType!VectorD == double));
	static assert(hasSwappableElements!VectorD);
	static assert(hasAssignableElements!VectorD);
}

///
unittest
{
	import std.range;

	alias VectorD = Vector!(const double);

	static assert(is(ElementType!VectorD == const double));
	static assert(hasSwappableElements!VectorD == false);
	static assert(hasAssignableElements!VectorD == false);

	static assert(isRandomAccessRange!VectorD);
	static assert(hasMobileElements!VectorD);
	static assert(hasLvalueElements!VectorD);
	static assert(hasLength!VectorD);
	static assert(hasSlicing!VectorD);
}


///
struct Matrix(T)
{
	///
	T* ptr;
	///
	size_t height;
	///
	size_t width;
	///
	ptrdiff_t shift;

	///
	mixin _D2!(Matrix, T);

	inout(T)[] data() inout
	{
		return ptr[0..height * shift];
	}

	///
	inout(T)* ptrEnd() inout
	{
		return ptr + height * shift;
	}

	///
	inout(typeof(this)) transpose() inout
	{
		import std.traits : Unqual;
		auto m = Matrix!(Unqual!T)(width, height);
		foreach(row; cast(Matrix!(T))this)
		{
			auto c = m.frontTransversal;
			m.popFrontTransversal;
			put(c, row);
		}
		return cast(typeof(return))m;
	}

	///
	inout(TransposedMatrix!T) transposed() inout
	{
		return typeof(return)(this);
	}

	///
	inout(Vector!T) transversal(size_t index) inout
	in
	{
		assert(index < lengthTransveral);
	}
	body
	{
		return typeof(return)(ptr+index, height, shift);
	}

	///
	size_t lengthTransveral() const @property
	{
		return width;
	}

	///
	bool emptyTransveral() const @property
	{
		return lengthTransveral == 0;
	}

	///
	inout(Vector!T) frontTransversal() inout
	in
	{
		assert(!emptyTransveral);
	}
	body
	{
		return typeof(return)(ptr, height, shift);
	}

	///
	void popFrontTransversal()
	in
	{
		assert(!emptyTransveral);
	}
	body
	{
		ptr++;
		width--;
	}

	///
	void popFrontNTransversal(size_t n)
	in
	{
		assert(n <= lengthTransveral);
	}
	body
	{
		ptr+=n;
		width-=n;
	}

	///
	inout(Vector!T) backTransversal() inout
	in
	{
		assert(!emptyTransveral);
	}
	body
	{
		return transversal(lengthTransveral-1);
	}

	///
	void popBackTransversal()
	in
	{
		assert(!emptyTransveral);
	}
	body
	{
		width--;
	}

	///
	void popBackNTransversal(size_t n)
	in
	{
		assert(n <= lengthTransveral);
	}
	body
	{
		width-=n;
	}

	///
	this(size_t height, size_t width) inout
	{
		this(height, width, width);
	}

	///
	this(inout(T)* ptr, size_t height, size_t width) inout
	{
		this(ptr, height, width, width);
	}

	///
	this(size_t height, size_t width, size_t shift) inout
	{
		this(new inout(T)[height * shift].ptr, height, width, shift);
	}

	///
	this(inout(T)* ptr, size_t height, size_t width, size_t shift) inout
	{
		this.ptr = ptr;
		this.height = height;
		this.width = width;
		this.shift = shift;
	}

	///
	inout(T)[] front() inout @property
	{
		assert(height);
		return ptr[0..width];
	}

	///
	void popFront()
	in
	{ 
		assert(!empty); 
	}
	body 
	{
		ptr += shift;
		height--;
	}

	///
	void popFrontN(size_t n)
	in
	{ 
		assert(height >= n); 
	}
	body 
	{
		ptr += shift*n;
		height -= n;
	}

	///
	inout(T)[] back() inout @property
	{
		assert(height);
		return (ptr+height-1)[0..width];
	}

	///
	void popBack()
	in
	{ 
		assert(!empty); 
	}
	body 
	{
		height--;
	}

	///
	void popBackN(size_t n)
	in
	{ 
		assert(height >= n); 
	}
	body 
	{
		height -= n;
	}


	inout(T)[] opIndex(size_t heightI) inout
	in
	{
		assert(heightI < height);
	}
	body 
	{
		auto l = heightI * shift;
		return ptr[l .. l + width];
	}

	///
	ref inout(T) opIndex(size_t heightI, size_t widthI) inout
	in
	{
		assert(heightI < height);
		assert(widthI < width);		
	}
	body 
	{
		return ptr[heightI * shift + widthI];
	}

	///
	inout(typeof(this)) opIndex(size_t[2] range) inout
	in
	{
		assert(range[1] <= height);
	}
	body 
	{
		return typeof(return)(ptr + shift * range[0], range[1] - range[0], width, shift);
	}

	///
	inout(typeof(this)) opIndex(size_t[2] range0, size_t[2] range1) inout
	in
	{
		assert(range0[1] <= height);
		assert(range1[1] <= width);
	}
	body 
	{
		return typeof(return)(ptr + range1[0] + shift * range0[0], range0[1] - range0[0], range1[1] - range1[0], shift);
	}

}

///
unittest
{
	import std.range;

	alias MatrixD = Matrix!double;

	static assert(is(ElementType!MatrixD == double[]));
	static assert(hasSwappableElements!MatrixD == false);
	static assert(hasAssignableElements!MatrixD == false);
	static assert(hasLvalueElements!MatrixD == false);
}

///
unittest
{
	import std.range, std.traits;
	import std.typetuple;

	foreach(M; TypeTuple!(Matrix!double, Matrix!(const double)))
	{
		static assert(isRandomAccessRange!M);
		static assert(hasMobileElements!M);
		static assert(isDynamicArray!(ElementType!M));
		static assert(hasLength!M);
		static assert(hasSlicing!M);
	}
}


///
struct TransposedMatrix(T)
{
	///
	Matrix!T matrix;

	///
	mixin _D2!(TransposedMatrix, T);

	///
	size_t width() const @property
	{
		return matrix.height;
	}

	///
	size_t height() const @property
	{
		return matrix.width;
	}

	///
	size_t lengthTransveral() const @property
	{
		return matrix.length;
	}

	///
	bool emptyTransveral() const @property
	{
		return matrix.empty;
	}

	///
	inout(Matrix!T) transposed() inout @property
	{
		return matrix;
	}
	
	inout(T)[] transversal(size_t index) inout @property
	in
	{
		assert(index < lengthTransveral);
	}
	body
	{
		return matrix[index];
	}

	///
	inout(T)[] frontTransversal() inout @property
	in
	{
		assert(!emptyTransveral);
	}
	body
	{
		return matrix.front;
	}

	///
	void popFrontTransversal()
	in
	{
		assert(!emptyTransveral);
	}
	body
	{
		matrix.popFront;
	}

	///
	void popFrontNTransversal(size_t n)
	in
	{
		assert(n <= lengthTransveral);
	}
	body
	{
		matrix.popFrontN(n);
	}

	///
	inout(T)[] backTransversal() inout @property
	in
	{
		assert(!emptyTransveral);
	}
	body
	{
		return matrix.back;
	}

	///
	void popBackTransversal()
	in
	{
		assert(!emptyTransveral);
	}
	body
	{
		matrix.popBack;
	}

	///
	void popBackNTransversal(size_t n)
	in
	{
		assert(n <= lengthTransveral);
	}
	body
	{
		matrix.popBackN(n);
	}

	///
	inout(Vector!T) front() inout @property
	in
	{
		assert(!empty);
	}
	body
	{
		return matrix.frontTransversal;
	}

	///
	void popFront()
	in
	{ 
		assert(!empty); 
	}
	body 
	{
		matrix.popFrontTransversal;
	}

	///
	void popFrontN(size_t n)
	in
	{ 
		assert(n <= length); 
	}
	body 
	{
		matrix.popFrontNTransversal(n);
	}

	///
	inout(Vector!T) back() inout @property
	in
	{
		assert(!empty);
	}
	body
	{
		return matrix.backTransversal;
	}

	///
	void popBack()
	in
	{ 
		assert(!empty);
	}
	body 
	{
		matrix.popBackTransversal;
	}

	///
	void popBackN(size_t n)
	in
	{ 
		assert(n <= length); 
	}
	body 
	{
		matrix.popBackNTransversal(n);
	}

	///
	auto opIndex(size_t heightI) inout
	in
	{
		assert(heightI < height);
	}
	body 
	{
		return matrix.transversal(heightI);
	}

	///
	ref inout(T) opIndex(size_t heightI, size_t widthI) inout
	in
	{
		assert(heightI < height);
		assert(widthI < width);		
	}
	body 
	{
		return matrix[widthI, heightI];
	}

	///
	inout(typeof(this))  opIndex(size_t[2] range) inout
	in
	{
		assert(range[1] <= height);
	}
	body 
	{
		return typeof(return)(inout(Matrix!T)(matrix.ptr + range[0], matrix.height, range[1] - range[0], matrix.shift));
	}

	///
	inout(typeof(this)) opIndex(size_t[2] range0, size_t[2] range1) inout
	in
	{
		assert(range0[1] <= height);
		assert(range1[1] <= width);
	}
	body 
	{
		return typeof(return)(matrix.opIndex(range1, range0));
	}
}


///
unittest
{
	import std.range;

	alias TransposedMatrixD = TransposedMatrix!double;

	static assert(is(ElementType!TransposedMatrixD == Vector!double));
	static assert(hasSwappableElements!TransposedMatrixD == false);
	static assert(hasAssignableElements!TransposedMatrixD == false);
	static assert(hasLvalueElements!TransposedMatrixD == false);
}

///
unittest
{
	import std.range, std.traits;
	import std.typetuple;

	foreach(M; TypeTuple!(TransposedMatrix!double, TransposedMatrix!(const double)))
	{
		static assert(isRandomAccessRange!M);
		static assert(hasMobileElements!M);
		static assert(hasLength!M);
		static assert(hasSlicing!M);
	}
}


/**
Stack of columns.
*/
struct SlidingWindow(T)
{
	///
	T[] data;

	///
	TransposedMatrix!T transposedMatrix;

	///
	alias transposedMatrix this;

	///
	this(size_t height, size_t maxWidth)
	body
	{
		data = new T[(height+1) * maxWidth];
		transposedMatrix = TransposedMatrix!T(Matrix!T(data.ptr, height, 0, maxWidth));
	}

	///
	void reset()
	{
		matrix.ptr = data.ptr;
		matrix.width = 0;
	}

	///
	void put(Range)(Range range)
		if(isInputRange!Range && hasLength!Range)
	in
	{
		assert(range.length == width);
	}
	body
	{
		if(matrix.ptrEnd-(matrix.shift-matrix.width) == data.ptr+data.length)
		{
			moveToFront();
		}
		assert(matrix.ptrEnd-(matrix.shift-matrix.width) < data.ptr+data.length);
		matrix.width++;
		assert(matrix.width <= matrix.shift);
		assert(matrix.shift * matrix.height <= data.length);
		range.copy(this.back);
	}


	///
	void reserveBackN(size_t n)
	in
	{
		assert(n <= matrix.shift);
		assert(n+matrix.width <= matrix.shift);
	}
	body
	{
		if(matrix.ptrEnd-(matrix.shift-matrix.width)+n > data.ptr+data.length)
		{
			moveToFront();
		}
		assert(matrix.ptrEnd-(matrix.shift-matrix.width)+n <= data.ptr+data.length);
		matrix.width+=n;
		assert(matrix.width <= matrix.shift);
		assert(matrix.shift * matrix.height <= data.length);
	}

	///
	void moveToFront()
	{
		if(length)
		{
			immutable shift = matrix.ptr-data.ptr;
			if(shift)
			{
				foreach(row; matrix)
				{
					(row.ptr-shift)[0..matrix.width] = row[];
				}
			}
		}
		matrix.ptr = data.ptr;
	}
}

///
unittest
{
	auto sl = SlidingWindow!double(4, 3);
	sl.put([0, 3, 6, 9]);
	sl.put([1, 4, 7, 9]);
	sl.put([2, 5, 8, 0]);
	assert(sl[1, 2] == 7);
	assert(sl.matrix[2, 1] == 7);
	sl.front.equal([0, 3, 6, 9]);
	sl.popFront();
	sl.front.equal([1, 4, 7, 9]);
	sl.backTransversal == [9, 0];
	foreach(i; 0..3)
	{
		assert(sl.matrix.ptr != sl.data.ptr);
		sl.put([i,i+4,i+8, 0]);
		sl.popFront();
	}
	assert(sl.matrix.ptr-1 == sl.data.ptr);
	sl.put([6, 7, 0, 3]);
	assert(sl.length == 3);
	assert(sl.matrix.length == 4);
	assert(sl.transversal(1) == [5, 6, 7]);
}


///
private template _D1(alias This, T)
{
	///
	bool empty() const @property
	{
		return length == 0;
	}

	///
	inout(typeof(this)) save() inout @property
	{
		return this;
	}

	///
	inout(typeof(this)) opIndex() inout
	{
		return this;
	}

	///
	size_t opDollar(size_t pos : 0)() const
	{
		return length;
	}

	///
	size_t[2] opSlice(size_t op)(size_t lb, size_t rb) const
	in
	{
		assert(lb <= rb);
	}
	body
	{
		return [lb, rb];
	}
}


///
private template _D2(alias This, T)
{
	///
	mixin _D1!(This, T);

	///
	size_t length() const @property
	{
		return height;
	}

	///
	size_t opDollar(size_t pos : 0)() const
	{
		return height;
	}

	///
	size_t opDollar(size_t pos : 1)() const
	{
		return width;
	}
}
